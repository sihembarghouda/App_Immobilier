// src/routes/ai.routes.js
const express = require('express');
const router = express.Router();
const aiController = require('../controllers/ai.controller');
const authMiddleware = require('../middleware/auth.middleware');

// Assistant AI conversationnel
router.post('/chat', aiController.chat);
router.get('/suggested-questions', aiController.getSuggestedQuestions);
router.post('/analyze-needs', authMiddleware, aiController.analyzeNeeds);
router.get('/conversation-history', authMiddleware, aiController.getConversationHistory);

// AI Recommendations pour acheteurs
router.get('/recommendations', authMiddleware, aiController.getRecommendations);

// AI Matching: trouver des acheteurs potentiels pour une propriété
router.get('/buyers/:propertyId', authMiddleware, aiController.getPotentialBuyers);

// Suggestions intelligentes basées sur l'historique
router.get('/suggestions', authMiddleware, aiController.getSmartSuggestions);

module.exports = router;
