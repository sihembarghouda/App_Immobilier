// src/routes/auth.routes.js
const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const authController = require('../controllers/auth.controller');
const authMiddleware = require('../middleware/auth.middleware');
const validate = require('../middleware/validation.middleware');

// Validation rules
const registerValidation = [
  body('email').isEmail().withMessage('Email invalide'),
  body('password').isLength({ min: 6 }).withMessage('Le mot de passe doit contenir au moins 6 caractères'),
  body('name').notEmpty().withMessage('Le nom est requis')
];

const loginValidation = [
  body('email').isEmail().withMessage('Email invalide'),
  body('password').notEmpty().withMessage('Le mot de passe est requis')
];

// Routes
router.post('/register', registerValidation, validate, authController.register);
router.post('/login', loginValidation, validate, authController.login);
router.get('/me', authMiddleware, authController.getCurrentUser);

module.exports = router;

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