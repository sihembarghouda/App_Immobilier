// src/controllers/upload.controller.js
const pool = require('../config/database');
const fs = require('fs');
const path = require('path');

// Upload web (generic multipart: field name 'image')
exports.uploadWeb = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ 
        success: false,
        message: 'Aucune image fournie' 
      });
    }

    // Determine actual relative path under /uploads
    const uploadsRoot = path.resolve(__dirname, '../../uploads');
    const absolute = path.resolve(req.file.path);
    let rel = path.relative(uploadsRoot, absolute).replace(/\\/g, '/');
    if (!rel || rel.startsWith('..')) {
      // Fallback to profiles
      rel = `profiles/${req.file.filename}`;
    }
    const imagePath = `/uploads/${rel}`;
    const absoluteUrl = `${req.protocol}://${req.get('host')}${imagePath}`;
// Upload single image
exports.uploadImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Aucun fichier uploadé'
      });
    }

    const fileUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;

    res.status(200).json({
      success: true,
      message: 'Image uploadée avec succès',
      imageUrl: absoluteUrl,
      imagePath,
      filename: req.file.filename
    });
  } catch (error) {
    console.error('Error uploading web image:', error);
    
    // Delete uploaded file on error
    if (req.file) {
      try {
        fs.unlinkSync(req.file.path);
      } catch (_) {}
    }
    
    res.status(500).json({ 
      success: false,
      message: 'Erreur lors du téléchargement de l\'image' 
    });
  }
};

// Upload profile image
exports.uploadProfileImage = async (req, res) => {
  const client = await pool.connect();
  
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Aucune image fournie' });
    }

    const userId = req.user.id;
    const imagePath = `/uploads/profiles/${req.file.filename}`;
    const absoluteUrl = `${req.protocol}://${req.get('host')}${imagePath}`;

    // Get old image to delete it
    const oldImageResult = await client.query(
      'SELECT avatar FROM users WHERE id = $1',
      [userId]
    );

    // Update user profile image
    await client.query(
      'UPDATE users SET avatar = $1 WHERE id = $2',
      [absoluteUrl, userId]
    );

    // Delete old image if exists
    if (oldImageResult.rows[0]?.avatar) {
      let oldImagePathStr = oldImageResult.rows[0].avatar;
      try {
        // If absolute URL stored previously, extract pathname
        if (typeof oldImagePathStr === 'string' && oldImagePathStr.startsWith('http')) {
          oldImagePathStr = new URL(oldImagePathStr).pathname;
        }
      } catch (_) {}
      const oldImagePath = path.join(__dirname, '../../', oldImagePathStr);
      if (fs.existsSync(oldImagePath)) {
        fs.unlinkSync(oldImagePath);
      }
    }

    res.json({
      message: 'Photo de profil mise à jour avec succès',
      imageUrl: absoluteUrl,
      imagePath
    });
  } catch (error) {
    console.error('Error uploading profile image:', error);
    
    // Delete uploaded file on error
    if (req.file) {
      const filePath = path.join(__dirname, '../../uploads/profiles', req.file.filename);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    }
    
    res.status(500).json({ error: 'Erreur lors du téléchargement de l\'image' });
  } finally {
    client.release();
  }
};

// Upload property images
exports.uploadPropertyImages = async (req, res) => {
  const client = await pool.connect();
  
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ error: 'Aucune image fournie' });
    }

    const { propertyId } = req.params;
    const userId = req.user.id;

    // Verify property ownership
    const propertyCheck = await client.query(
      'SELECT owner_id FROM properties WHERE id = $1',
      [propertyId]
    );

    if (propertyCheck.rows.length === 0) {
      // Delete uploaded files
      req.files.forEach(file => {
        const filePath = path.join(__dirname, '../../uploads/properties', file.filename);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      });
      return res.status(404).json({ error: 'Propriété non trouvée' });
    }

    if (propertyCheck.rows[0].owner_id !== userId) {
      // Delete uploaded files
      req.files.forEach(file => {
        const filePath = path.join(__dirname, '../../uploads/properties', file.filename);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      });
      return res.status(403).json({ error: 'Non autorisé' });
    }

    // Build array of image URLs
    const imageUrls = req.files.map(file => `/uploads/properties/${file.filename}`);

    // Get existing images
    const existingResult = await client.query(
      'SELECT images FROM properties WHERE id = $1',
      [propertyId]
    );

    const existingImages = existingResult.rows[0]?.images || [];
    const updatedImages = [...existingImages, ...imageUrls];

    // Update property images
    await client.query(
      'UPDATE properties SET images = $1 WHERE id = $2',
      [updatedImages, propertyId]
    );

    res.json({
      message: 'Images ajoutées avec succès',
      images: updatedImages
    });
  } catch (error) {
    console.error('Error uploading property images:', error);
    
    // Delete uploaded files on error
    if (req.files) {
      req.files.forEach(file => {
        const filePath = path.join(__dirname, '../../uploads/properties', file.filename);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      });
    }
    
    res.status(500).json({ error: 'Erreur lors du téléchargement des images' });
  } finally {
    client.release();
  }
};

// Delete property image
exports.deletePropertyImage = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { propertyId } = req.params;
    const { imageUrl } = req.body;
    const userId = req.user.id;

    // Verify property ownership
    const propertyCheck = await client.query(
      'SELECT owner_id, images FROM properties WHERE id = $1',
      [propertyId]
    );

    if (propertyCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Propriété non trouvée' });
    }

    if (propertyCheck.rows[0].owner_id !== userId) {
      return res.status(403).json({ error: 'Non autorisé' });
    }

    const existingImages = propertyCheck.rows[0].images || [];
    const updatedImages = existingImages.filter(img => img !== imageUrl);

    // Update property images
    await client.query(
      'UPDATE properties SET images = $1 WHERE id = $2',
      [updatedImages, propertyId]
    );

    // Delete file from filesystem
    const filePath = path.join(__dirname, '../../', imageUrl);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    res.json({
      message: 'Image supprimée avec succès',
      images: updatedImages
    });
  } catch (error) {
    console.error('Error deleting property image:', error);
    res.status(500).json({ error: 'Erreur lors de la suppression de l\'image' });
  } finally {
    client.release();
      data: {
        filename: req.file.filename,
        url: fileUrl,
        size: req.file.size,
        mimetype: req.file.mimetype
      }
    });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'upload'
    });
  }
};

// Upload multiple images
exports.uploadMultipleImages = async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Aucun fichier uploadé'
      });
    }

    const files = req.files.map(file => ({
      filename: file.filename,
      url: `${req.protocol}://${req.get('host')}/uploads/${file.filename}`,
      size: file.size,
      mimetype: file.mimetype
    }));

    res.status(200).json({
      success: true,
      message: `${files.length} image(s) uploadée(s) avec succès`,
      data: files
    });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'upload'
    });
  }
};
