// src/routes/favorite.routes.js
const express = require('express');
const router = express.Router();
const favoriteController = require('../controllers/favorite.controller');
const authMiddleware = require('../middleware/auth.middleware');

// All routes require authentication
router.use(authMiddleware);

// Routes
router.get('/', favoriteController.getUserFavorites);
router.post('/', favoriteController.addFavorite);
router.delete('/:propertyId', favoriteController.removeFavorite);

module.exports = router;

// src/controllers/favorite.controller.js
const pool = require('../config/database');

// Get user favorites
exports.getUserFavorites = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const result = await client.query(
      `SELECT 
        p.*,
        u.name as owner_name,
        u.phone as owner_phone,
        u.avatar as owner_avatar,
        true as is_favorite
      FROM favorites f
      JOIN properties p ON f.property_id = p.id
      LEFT JOIN users u ON p.owner_id = u.id
      WHERE f.user_id = $1
      ORDER BY f.created_at DESC`,
      [req.user.id]
    );

    res.status(200).json({
      success: true,
      count: result.rows.length,
      data: result.rows
    });
  } catch (error) {
    console.error('Get favorites error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des favoris'
    });
  } finally {
    client.release();
  }
};

// Add favorite
exports.addFavorite = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { property_id } = req.body;

    if (!property_id) {
      return res.status(400).json({
        success: false,
        message: 'property_id est requis'
      });
    }

    // Check if property exists
    const propertyExists = await client.query(
      'SELECT id FROM properties WHERE id = $1',
      [property_id]
    );

    if (propertyExists.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Propriété non trouvée'
      });
    }

    // Check if already in favorites
    const alreadyFavorite = await client.query(
      'SELECT id FROM favorites WHERE user_id = $1 AND property_id = $2',
      [req.user.id, property_id]
    );

    if (alreadyFavorite.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Cette propriété est déjà dans vos favoris'
      });
    }

    // Add to favorites
    await client.query(
      'INSERT INTO favorites (user_id, property_id) VALUES ($1, $2)',
      [req.user.id, property_id]
    );

    res.status(201).json({
      success: true,
      message: 'Ajouté aux favoris'
    });
  } catch (error) {
    console.error('Add favorite error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'ajout aux favoris'
    });
  } finally {
    client.release();
  }
};

// Remove favorite
exports.removeFavorite = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { propertyId } = req.params;

    const result = await client.query(
      'DELETE FROM favorites WHERE user_id = $1 AND property_id = $2 RETURNING id',
      [req.user.id, propertyId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Favori non trouvé'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Retiré des favoris'
    });
  } catch (error) {
    console.error('Remove favorite error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression du favori'
    });
  } finally {
    client.release();
  }
};