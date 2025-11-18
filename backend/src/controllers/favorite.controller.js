// src/controllers/favorite.controller.js
const pool = require('../config/database');

// Get user favorites
exports.getUserFavorites = async (req, res) => {
  const client = await pool.connect();
  
  try {
    // Check authentication
    if (!req.user || !req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Non authentifié'
      });
    }

    console.log('📂 Fetching favorites for user:', req.user.id);
    
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

    console.log(`✅ Found ${result.rows.length} favorites`);

    res.status(200).json({
      success: true,
      count: result.rows.length,
      data: result.rows
    });
  } catch (error) {
    console.error('❌ Get favorites error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des favoris',
      error: error.message
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

    // Check if user is authenticated
    if (!req.user || !req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Vous devez être connecté pour ajouter aux favoris'
      });
    }

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
      // Return 200 OK (idempotent operation) instead of 400
      return res.status(200).json({
        success: true,
        message: 'Cette propriété est déjà dans vos favoris',
        data: { id: alreadyFavorite.rows[0].id, property_id, user_id: req.user.id }
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
