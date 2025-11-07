// src/routes/property.routes.js
const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const propertyController = require('../controllers/property.controller');
const authMiddleware = require('../middleware/auth.middleware');
const validate = require('../middleware/validation.middleware');

// Validation rules
const propertyValidation = [
  body('title').notEmpty().withMessage('Le titre est requis'),
  body('description').notEmpty().withMessage('La description est requise'),
  body('type').isIn(['apartment', 'house', 'villa', 'studio']).withMessage('Type invalide'),
  body('transaction_type').isIn(['sale', 'rent']).withMessage('Type de transaction invalide'),
  body('price').isFloat({ min: 0 }).withMessage('Le prix doit être positif'),
  body('surface').isFloat({ min: 0 }).withMessage('La surface doit être positive'),
  body('rooms').isInt({ min: 1 }).withMessage('Le nombre de pièces doit être au moins 1'),
  body('bedrooms').isInt({ min: 0 }).withMessage('Le nombre de chambres doit être positif'),
  body('bathrooms').isInt({ min: 0 }).withMessage('Le nombre de salles de bain doit être positif'),
  body('address').notEmpty().withMessage('L\'adresse est requise'),
  body('city').notEmpty().withMessage('La ville est requise'),
  body('latitude').isFloat().withMessage('Latitude invalide'),
  body('longitude').isFloat().withMessage('Longitude invalide')
];

// Routes
router.get('/', propertyController.getAllProperties);
router.get('/:id', propertyController.getPropertyById);
router.post('/', authMiddleware, propertyValidation, validate, propertyController.createProperty);
router.put('/:id', authMiddleware, propertyValidation, validate, propertyController.updateProperty);
router.delete('/:id', authMiddleware, propertyController.deleteProperty);

module.exports = router;

// src/controllers/property.controller.js
const pool = require('../config/database');

// Get all properties with filters
exports.getAllProperties = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const {
      city,
      type,
      transaction_type,
      min_price,
      max_price,
      min_rooms,
      max_rooms,
      min_surface,
      max_surface
    } = req.query;

    let query = `
      SELECT 
        p.*,
        u.name as owner_name,
        u.phone as owner_phone,
        u.avatar as owner_avatar,
        EXISTS(
          SELECT 1 FROM favorites f 
          WHERE f.property_id = p.id AND f.user_id = $1
        ) as is_favorite
      FROM properties p
      LEFT JOIN users u ON p.owner_id = u.id
      WHERE 1=1
    `;
    
    const params = [req.user?.id || null];
    let paramIndex = 2;

    // Build dynamic query based on filters
    if (city) {
      query += ` AND LOWER(p.city) LIKE LOWER($${paramIndex})`;
      params.push(`%${city}%`);
      paramIndex++;
    }

    if (type) {
      query += ` AND p.type = $${paramIndex}`;
      params.push(type);
      paramIndex++;
    }

    if (transaction_type) {
      query += ` AND p.transaction_type = $${paramIndex}`;
      params.push(transaction_type);
      paramIndex++;
    }

    if (min_price) {
      query += ` AND p.price >= $${paramIndex}`;
      params.push(min_price);
      paramIndex++;
    }

    if (max_price) {
      query += ` AND p.price <= $${paramIndex}`;
      params.push(max_price);
      paramIndex++;
    }

    if (min_rooms) {
      query += ` AND p.rooms >= $${paramIndex}`;
      params.push(min_rooms);
      paramIndex++;
    }

    if (max_rooms) {
      query += ` AND p.rooms <= $${paramIndex}`;
      params.push(max_rooms);
      paramIndex++;
    }

    if (min_surface) {
      query += ` AND p.surface >= $${paramIndex}`;
      params.push(min_surface);
      paramIndex++;
    }

    if (max_surface) {
      query += ` AND p.surface <= $${paramIndex}`;
      params.push(max_surface);
      paramIndex++;
    }

    query += ' ORDER BY p.created_at DESC';

    const result = await client.query(query, params);

    res.status(200).json({
      success: true,
      count: result.rows.length,
      data: result.rows
    });
  } catch (error) {
    console.error('Get properties error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des propriétés'
    });
  } finally {
    client.release();
  }
};

// Get property by ID
exports.getPropertyById = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { id } = req.params;

    const result = await client.query(
      `SELECT 
        p.*,
        u.name as owner_name,
        u.phone as owner_phone,
        u.avatar as owner_avatar,
        u.email as owner_email,
        EXISTS(
          SELECT 1 FROM favorites f 
          WHERE f.property_id = p.id AND f.user_id = $1
        ) as is_favorite
      FROM properties p
      LEFT JOIN users u ON p.owner_id = u.id
      WHERE p.id = $2`,
      [req.user?.id || null, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Propriété non trouvée'
      });
    }

    res.status(200).json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Get property error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération de la propriété'
    });
  } finally {
    client.release();
  }
};

// Create property
exports.createProperty = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const {
      title,
      description,
      type,
      transaction_type,
      price,
      surface,
      rooms,
      bedrooms,
      bathrooms,
      address,
      city,
      latitude,
      longitude,
      images
    } = req.body;

    const result = await client.query(
      `INSERT INTO properties 
        (title, description, type, transaction_type, price, surface, rooms, bedrooms, 
         bathrooms, address, city, latitude, longitude, images, owner_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
       RETURNING *`,
      [
        title, description, type, transaction_type, price, surface, rooms, bedrooms,
        bathrooms, address, city, latitude, longitude, images || [], req.user.id
      ]
    );

    res.status(201).json({
      success: true,
      message: 'Propriété créée avec succès',
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Create property error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la création de la propriété'
    });
  } finally {
    client.release();
  }
};

// Update property
exports.updateProperty = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { id } = req.params;
    const {
      title,
      description,
      type,
      transaction_type,
      price,
      surface,
      rooms,
      bedrooms,
      bathrooms,
      address,
      city,
      latitude,
      longitude,
      images
    } = req.body;

    // Check if property exists and belongs to user
    const checkResult = await client.query(
      'SELECT owner_id FROM properties WHERE id = $1',
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Propriété non trouvée'
      });
    }

    if (checkResult.rows[0].owner_id !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Non autorisé à modifier cette propriété'
      });
    }

    // Update property
    const result = await client.query(
      `UPDATE properties 
       SET title = $1, description = $2, type = $3, transaction_type = $4, 
           price = $5, surface = $6, rooms = $7, bedrooms = $8, bathrooms = $9,
           address = $10, city = $11, latitude = $12, longitude = $13, images = $14
       WHERE id = $15
       RETURNING *`,
      [
        title, description, type, transaction_type, price, surface, rooms, bedrooms,
        bathrooms, address, city, latitude, longitude, images, id
      ]
    );

    res.status(200).json({
      success: true,
      message: 'Propriété mise à jour avec succès',
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Update property error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour de la propriété'
    });
  } finally {
    client.release();
  }
};

// Delete property
exports.deleteProperty = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { id } = req.params;

    // Check if property exists and belongs to user
    const checkResult = await client.query(
      'SELECT owner_id FROM properties WHERE id = $1',
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Propriété non trouvée'
      });
    }

    if (checkResult.rows[0].owner_id !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Non autorisé à supprimer cette propriété'
      });
    }

    // Delete property
    await client.query('DELETE FROM properties WHERE id = $1', [id]);

    res.status(200).json({
      success: true,
      message: 'Propriété supprimée avec succès'
    });
  } catch (error) {
    console.error('Delete property error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression de la propriété'
    });
  } finally {
    client.release();
  }
};