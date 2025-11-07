// src/routes/upload.routes.js
const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/upload.controller');
const authMiddleware = require('../middleware/auth.middleware');
const upload = require('../config/multer');

// Routes
router.post('/', authMiddleware, upload.single('image'), uploadController.uploadImage);
router.post('/multiple', authMiddleware, upload.array('images', 10), uploadController.uploadMultipleImages);

module.exports = router;

// src/config/multer.js
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Create uploads directory if it doesn't exist
const uploadDir = process.env.UPLOAD_DIR || './uploads';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Configure storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'property-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// File filter - only images
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);

  if (extname && mimetype) {
    cb(null, true);
  } else {
    cb(new Error('Seules les images sont autorisées (jpeg, jpg, png, gif, webp)'));
  }
};

// Configure multer
const upload = multer({
  storage: storage,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5 * 1024 * 1024 // 5MB
  },
  fileFilter: fileFilter
});

module.exports = upload;

// src/controllers/upload.controller.js
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