// src/controllers/auth.controller.js
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');

// Generate JWT token
const generateToken = (user) => {
  return jwt.sign(
    { id: user.id, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
};

// Register
exports.register = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { email, password, name, phone, role } = req.body;

    // Normaliser le rôle (convertir 'visitor' → 'visiteur' pour compatibilité)
    let normalizedRole = role || 'visiteur';
    if (normalizedRole === 'visitor') {
      normalizedRole = 'visiteur';
    } else if (normalizedRole === 'buyer') {
      normalizedRole = 'acheteur';
    } else if (normalizedRole === 'seller') {
      normalizedRole = 'vendeur';
    }
    const { email, password, name, phone } = req.body;

    // Check if user already exists
    const userExists = await client.query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );

    if (userExists.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Cet email est déjà utilisé'
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user
    const result = await client.query(
      `INSERT INTO users (email, password, name, phone, role) 
       VALUES ($1, $2, $3, $4, $5) 
       RETURNING id, email, name, phone, role, created_at`,
      [email, hashedPassword, name, phone, normalizedRole]
      `INSERT INTO users (email, password, name, phone) 
       VALUES ($1, $2, $3, $4) 
       RETURNING id, email, name, phone, created_at`,
      [email, hashedPassword, name, phone]
    );

    const user = result.rows[0];

    // Generate token
    const token = generateToken(user);

    res.status(201).json({
      success: true,
      message: 'Inscription réussie',
      data: {
        token,
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          phone: user.phone,
          role: user.role,
          created_at: user.created_at
        }
      }
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'inscription'
    });
  } finally {
    client.release();
  }
};

// Login
exports.login = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { email, password } = req.body;

    // Find user
    const result = await client.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Email ou mot de passe incorrect'
      });
    }

    const user = result.rows[0];

    // Check password
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Email ou mot de passe incorrect'
      });
    }

    // Generate token
    const token = generateToken(user);

    res.status(200).json({
      success: true,
      message: 'Connexion réussie',
      data: {
        token,
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          phone: user.phone,
          avatar: user.avatar,
          role: user.role,
          created_at: user.created_at
        }
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la connexion'
    });
  } finally {
    client.release();
  }
};

// Get current user
exports.getCurrentUser = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const result = await client.query(
      'SELECT id, email, name, phone, avatar, role, created_at FROM users WHERE id = $1',
      'SELECT id, email, name, phone, avatar, created_at FROM users WHERE id = $1',
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Utilisateur non trouvé'
      });
    }

    res.status(200).json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération de l\'utilisateur'
    });
  } finally {
    client.release();
  }
};

// Update user profile (name, phone, avatar, and optionally role)
exports.updateProfile = async (req, res) => {
  const client = await pool.connect();
  
  try {
    if (!req.user || !req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Non authentifié'
      });
    }

    const { name, phone, avatar, role } = req.body;

    // Optional role update with validation (supports FR and EN variants)
    let roleToUpdate = null;
    if (typeof role === 'string') {
      const input = role.trim().toLowerCase();
      const allowed = new Set([
        'visitor', 'buyer', 'seller',
        'visiteur', 'acheteur', 'vendeur'
      ]);

      if (!allowed.has(input)) {
        return res.status(400).json({
          success: false,
          message: "Rôle invalide. Valeurs acceptées: visitor/buyer/seller ou visiteur/acheteur/vendeur"
        });
      }
      // Normalize FR -> EN for DB compatibility
      const frToEnMap = {
        'visiteur': 'visitor',
        'acheteur': 'buyer',
        'vendeur': 'seller'
      };
      roleToUpdate = frToEnMap[input] || input; // if EN already, keep as-is
    }

    // Load current values to avoid NULL update issues
    const current = await client.query(
      'SELECT name, phone, avatar FROM users WHERE id = $1',
      [req.user.id]
    );

    const newName = typeof name === 'string' && name.trim() ? name.trim() : current.rows[0].name;
    const newPhone = typeof phone === 'string' ? phone : current.rows[0].phone;
    const newAvatar = typeof avatar === 'string' && avatar.trim() ? avatar.trim() : current.rows[0].avatar;

    const params = [newName, newPhone, newAvatar, req.user.id];
    let updateSql = `UPDATE users 
       SET name = $1, phone = $2, avatar = $3, updated_at = CURRENT_TIMESTAMP`;

    if (roleToUpdate) {
      // Update role as provided (DB may enforce allowed values)
      updateSql += `, role = $5`;
    }

    updateSql += ` WHERE id = $4 RETURNING id, email, name, phone, avatar, role, created_at`;

    const result = await client.query(
      updateSql,
      roleToUpdate ? [...params, roleToUpdate] : params
    );

    res.status(200).json({
      success: true,
      message: 'Profil mis à jour avec succès',
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour du profil'
    });
  } finally {
    client.release();
  }
};

// Delete account
exports.deleteAccount = async (req, res) => {
  const client = await pool.connect();
  
  try {
    if (!req.user || !req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Non authentifié'
      });
    }

    const userId = req.user.id;
    
    await client.query('BEGIN');

    // Delete user's properties
    await client.query('DELETE FROM properties WHERE owner_id = $1', [userId]);
    
    // Delete user's favorites
    await client.query('DELETE FROM favorites WHERE user_id = $1', [userId]);
    
    // Delete user's messages (sent and received)
    await client.query('DELETE FROM messages WHERE sender_id = $1 OR receiver_id = $1', [userId]);
    
    // Delete user
    await client.query('DELETE FROM users WHERE id = $1', [userId]);

    await client.query('COMMIT');

    res.status(200).json({
      success: true,
      message: 'Compte supprimé avec succès'
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Delete account error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression du compte'
    });
  } finally {
    client.release();
  }
};
