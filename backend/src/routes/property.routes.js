// src/routes/property.routes.js
const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const propertyController = require('../controllers/property.controller');
const authMiddleware = require('../middleware/auth.middleware');
const { requireAuthenticated, canEditProperty } = require('../middleware/role.middleware');
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
// Allow any authenticated user to create properties (simplified roles)
router.post('/', authMiddleware, requireAuthenticated, propertyValidation, validate, propertyController.createProperty);
router.put('/:id', authMiddleware, canEditProperty, propertyValidation, validate, propertyController.updateProperty);
router.delete('/:id', authMiddleware, canEditProperty, propertyController.deleteProperty);

module.exports = router;
module.exports = router;
