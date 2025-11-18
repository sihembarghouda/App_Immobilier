// src/routes/message.routes.js
const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const messageController = require('../controllers/message.controller');
const authMiddleware = require('../middleware/auth.middleware');
const validate = require('../middleware/validation.middleware');

// All routes require authentication
router.use(authMiddleware);

// Validation
const messageValidation = [
  body('receiver_id').isInt().withMessage('receiver_id invalide'),
  body('content').notEmpty().withMessage('Le contenu est requis')
];

// Routes
router.get('/conversations', messageController.getConversations);
router.get('/:userId', messageController.getMessagesWithUser);
router.post('/', messageValidation, validate, messageController.sendMessage);
router.put('/:userId/read', messageController.markMessagesAsRead);

module.exports = router;
// src/routes/message.routes.js
const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const messageController = require('../controllers/message.controller');
const authMiddleware = require('../middleware/auth.middleware');
const validate = require('../middleware/validation.middleware');

// All routes require authentication
router.use(authMiddleware);

// Validation
const messageValidation = [
  body('receiver_id').isInt().withMessage('receiver_id invalide'),
  body('content').notEmpty().withMessage('Le contenu est requis')
];

// Routes
router.get('/conversations', messageController.getConversations);
router.get('/:userId', messageController.getMessagesWithUser);
router.post('/', messageValidation, validate, messageController.sendMessage);
router.put('/:userId/read', messageController.markMessagesAsRead);

module.exports = router;
