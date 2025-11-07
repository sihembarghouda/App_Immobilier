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

// src/controllers/message.controller.js
const pool = require('../config/database');

// Get all conversations
exports.getConversations = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const result = await client.query(
      `WITH latest_messages AS (
        SELECT DISTINCT ON (
          CASE 
            WHEN sender_id = $1 THEN receiver_id 
            ELSE sender_id 
          END
        )
          m.*,
          CASE 
            WHEN sender_id = $1 THEN receiver_id 
            ELSE sender_id 
          END as other_user_id
        FROM messages m
        WHERE sender_id = $1 OR receiver_id = $1
        ORDER BY 
          CASE 
            WHEN sender_id = $1 THEN receiver_id 
            ELSE sender_id 
          END,
          created_at DESC
      ),
      unread_counts AS (
        SELECT 
          sender_id as other_user_id,
          COUNT(*) as unread_count
        FROM messages
        WHERE receiver_id = $1 AND is_read = false
        GROUP BY sender_id
      )
      SELECT 
        lm.id,
        lm.other_user_id,
        u.name as other_user_name,
        u.avatar as other_user_avatar,
        json_build_object(
          'id', lm.id,
          'sender_id', lm.sender_id,
          'receiver_id', lm.receiver_id,
          'content', lm.content,
          'is_read', lm.is_read,
          'created_at', lm.created_at
        ) as last_message,
        COALESCE(uc.unread_count, 0) as unread_count,
        lm.created_at as updated_at
      FROM latest_messages lm
      LEFT JOIN users u ON u.id = lm.other_user_id
      LEFT JOIN unread_counts uc ON uc.other_user_id = lm.other_user_id
      ORDER BY lm.created_at DESC`,
      [req.user.id]
    );

    res.status(200).json({
      success: true,
      count: result.rows.length,
      data: result.rows
    });
  } catch (error) {
    console.error('Get conversations error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des conversations'
    });
  } finally {
    client.release();
  }
};

// Get messages with a specific user
exports.getMessagesWithUser = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { userId } = req.params;

    const result = await client.query(
      `SELECT 
        m.*,
        s.name as sender_name,
        s.avatar as sender_avatar,
        r.name as receiver_name,
        r.avatar as receiver_avatar
      FROM messages m
      LEFT JOIN users s ON m.sender_id = s.id
      LEFT JOIN users r ON m.receiver_id = r.id
      WHERE 
        (m.sender_id = $1 AND m.receiver_id = $2) OR
        (m.sender_id = $2 AND m.receiver_id = $1)
      ORDER BY m.created_at DESC
      LIMIT 100`,
      [req.user.id, userId]
    );

    res.status(200).json({
      success: true,
      count: result.rows.length,
      data: result.rows
    });
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des messages'
    });
  } finally {
    client.release();
  }
};

// Send message
exports.sendMessage = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { receiver_id, content, property_id } = req.body;

    // Check if receiver exists
    const receiverExists = await client.query(
      'SELECT id, name, avatar FROM users WHERE id = $1',
      [receiver_id]
    );

    if (receiverExists.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Destinataire non trouvé'
      });
    }

    // Get sender info
    const senderInfo = await client.query(
      'SELECT name, avatar FROM users WHERE id = $1',
      [req.user.id]
    );

    // Insert message
    const result = await client.query(
      `INSERT INTO messages (sender_id, receiver_id, content, property_id)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [req.user.id, receiver_id, content, property_id || null]
    );

    const message = result.rows[0];

    // Add user info to response
    const responseData = {
      ...message,
      sender_name: senderInfo.rows[0].name,
      sender_avatar: senderInfo.rows[0].avatar,
      receiver_name: receiverExists.rows[0].name,
      receiver_avatar: receiverExists.rows[0].avatar
    };

    res.status(201).json({
      success: true,
      message: 'Message envoyé',
      data: responseData
    });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'envoi du message'
    });
  } finally {
    client.release();
  }
};

// Mark messages as read
exports.markMessagesAsRead = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { userId } = req.params;

    await client.query(
      `UPDATE messages 
       SET is_read = true 
       WHERE sender_id = $1 AND receiver_id = $2 AND is_read = false`,
      [userId, req.user.id]
    );

    res.status(200).json({
      success: true,
      message: 'Messages marqués comme lus'
    });
  } catch (error) {
    console.error('Mark as read error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors du marquage des messages'
    });
  } finally {
    client.release();
  }
};