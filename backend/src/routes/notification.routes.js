// routes/notification.routes.js
const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notification.controller');
const authMiddleware = require('../middleware/auth.middleware');

// Toutes les routes protégées
router.get('/', authMiddleware, notificationController.getNotifications);
router.get('/unread-count', authMiddleware, notificationController.getUnreadCount);
router.put('/:notificationId/read', authMiddleware, notificationController.markAsRead);
router.put('/read-all', authMiddleware, notificationController.markAllAsRead);
router.delete('/:notificationId', authMiddleware, notificationController.deleteNotification);

module.exports = router;
