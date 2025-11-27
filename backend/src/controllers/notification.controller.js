// controllers/notification.controller.js
const pool = require('../config/database');
const websocketService = require('../services/websocket.service');

// Obtenir les notifications de l'utilisateur
exports.getNotifications = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const userId = req.user.id;
    const { limit = 50, offset = 0, unreadOnly = false } = req.query;

    let query = `
      SELECT * FROM notifications
      WHERE user_id = $1
    `;

    const params = [userId];

    if (unreadOnly === 'true') {
      query += ' AND read = false';
    }

    query += ` ORDER BY created_at DESC LIMIT $2 OFFSET $3`;
    params.push(limit, offset);

    const result = await client.query(query, params);

    // Compter les non lues
    const unreadCount = await client.query(
      'SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND read = false',
      [userId]
    );

    res.json({
      success: true,
      data: {
        notifications: result.rows,
        unreadCount: parseInt(unreadCount.rows[0].count),
        total: result.rowCount
      }
    });
  } catch (error) {
    console.error('Get notifications error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des notifications'
    });
  } finally {
    client.release();
  }
};

// Marquer une notification comme lue
exports.markAsRead = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const userId = req.user.id;
    const { notificationId } = req.params;

    await client.query(
      `UPDATE notifications 
       SET read = true, read_at = CURRENT_TIMESTAMP
       WHERE id = $1 AND user_id = $2`,
      [notificationId, userId]
    );

    res.json({
      success: true,
      message: 'Notification marquée comme lue'
    });
  } catch (error) {
    console.error('Mark as read error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour'
    });
  } finally {
    client.release();
  }
};

// Marquer toutes les notifications comme lues
exports.markAllAsRead = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const userId = req.user.id;

    await client.query(
      `UPDATE notifications 
       SET read = true, read_at = CURRENT_TIMESTAMP
       WHERE user_id = $1 AND read = false`,
      [userId]
    );

    res.json({
      success: true,
      message: 'Toutes les notifications marquées comme lues'
    });
  } catch (error) {
    console.error('Mark all as read error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour'
    });
  } finally {
    client.release();
  }
};

// Supprimer une notification
exports.deleteNotification = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const userId = req.user.id;
    const { notificationId } = req.params;

    await client.query(
      'DELETE FROM notifications WHERE id = $1 AND user_id = $2',
      [notificationId, userId]
    );

    res.json({
      success: true,
      message: 'Notification supprimée'
    });
  } catch (error) {
    console.error('Delete notification error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression'
    });
  } finally {
    client.release();
  }
};

// Créer une notification (usage interne)
exports.createNotification = async (userId, type, title, message, data = {}) => {
  const client = await pool.connect();
  
  try {
    const result = await client.query(
      `INSERT INTO notifications (user_id, type, title, message, data)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [userId, type, title, message, JSON.stringify(data)]
    );

    const notification = result.rows[0];

    // Envoyer en temps réel via WebSocket
    websocketService.sendNotificationToUser(userId, notification);

    return notification;
  } catch (error) {
    console.error('Create notification error:', error);
    return null;
  } finally {
    client.release();
  }
};

// Obtenir le nombre de notifications non lues
exports.getUnreadCount = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const userId = req.user.id;

    const result = await client.query(
      'SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND read = false',
      [userId]
    );

    res.json({
      success: true,
      data: {
        count: parseInt(result.rows[0].count)
      }
    });
  } catch (error) {
    console.error('Get unread count error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération'
    });
  } finally {
    client.release();
  }
};

module.exports = exports;
