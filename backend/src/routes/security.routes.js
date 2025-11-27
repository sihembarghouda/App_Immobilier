// routes/security.routes.js
const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const securityController = require('../controllers/security.controller');
const authMiddleware = require('../middleware/auth.middleware');
const validate = require('../middleware/validation.middleware');

// Validation rules
const changePasswordValidation = [
  body('currentPassword').notEmpty().withMessage('Mot de passe actuel requis'),
  body('newPassword').isLength({ min: 6 }).withMessage('Le nouveau mot de passe doit contenir au moins 6 caractères')
];

const enable2FAValidation = [
  body('token').isLength({ min: 6, max: 6 }).withMessage('Code de vérification invalide')
];

const disable2FAValidation = [
  body('password').notEmpty().withMessage('Mot de passe requis')
];

// Routes (toutes protégées par authMiddleware)
router.post('/change-password', authMiddleware, changePasswordValidation, validate, securityController.changePassword);
router.post('/2fa/generate', authMiddleware, securityController.generateTwoFactorSecret);
router.post('/2fa/enable', authMiddleware, enable2FAValidation, validate, securityController.enableTwoFactor);
router.post('/2fa/disable', authMiddleware, disable2FAValidation, validate, securityController.disableTwoFactor);
router.get('/sessions', authMiddleware, securityController.getActiveSessions);
router.delete('/sessions/:sessionId', authMiddleware, securityController.revokeSession);
router.delete('/sessions', authMiddleware, securityController.revokeAllSessions);

module.exports = router;
