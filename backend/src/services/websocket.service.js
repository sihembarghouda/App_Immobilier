// services/websocket.service.js
const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');

class WebSocketService {
  constructor() {
    this.io = null;
    this.userSockets = new Map(); // userId -> socketId
  }

  initialize(server) {
    this.io = new Server(server, {
      cors: {
        origin: '*',
        methods: ['GET', 'POST']
      }
    });

    // Middleware pour authentification
    this.io.use(async (socket, next) => {
      try {
        const token = socket.handshake.auth.token;
        
        if (!token) {
          return next(new Error('Authentication error'));
        }

        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        socket.userId = decoded.id;
        socket.userEmail = decoded.email;
        
        next();
      } catch (error) {
        console.error('Socket auth error:', error);
        next(new Error('Authentication error'));
      }
    });

    this.io.on('connection', async (socket) => {
      console.log(`✅ User ${socket.userId} connected (${socket.id})`);
      
      // Enregistrer la connexion
      this.userSockets.set(socket.userId, socket.id);
      await this.updateUserPresence(socket.userId, true, socket.id);

      // Notifier les autres utilisateurs
      socket.broadcast.emit('user-online', {
        userId: socket.userId,
        timestamp: new Date().toISOString()
      });

      // Événement: demande de statut d'un utilisateur
      socket.on('check-user-status', async (targetUserId) => {
        const isOnline = this.userSockets.has(targetUserId);
        const presence = await this.getUserPresence(targetUserId);
        
        socket.emit('user-status', {
          userId: targetUserId,
          isOnline,
          lastSeen: presence?.last_seen
        });
      });

      // Événement: déconnexion
      socket.on('disconnect', async () => {
        console.log(`❌ User ${socket.userId} disconnected`);
        
        this.userSockets.delete(socket.userId);
        await this.updateUserPresence(socket.userId, false);

        // Notifier les autres utilisateurs
        socket.broadcast.emit('user-offline', {
          userId: socket.userId,
          timestamp: new Date().toISOString()
        });
      });

      // Événement: message en cours de frappe
      socket.on('typing', (data) => {
        socket.to(data.recipientId).emit('user-typing', {
          userId: socket.userId,
          conversationId: data.conversationId
        });
      });

      // Événement: arrêt de frappe
      socket.on('stop-typing', (data) => {
        socket.to(data.recipientId).emit('user-stop-typing', {
          userId: socket.userId,
          conversationId: data.conversationId
        });
      });

      // Événement: nouveau message
      socket.on('new-message', async (data) => {
        const recipientSocketId = this.userSockets.get(data.recipientId);
        
        if (recipientSocketId) {
          this.io.to(recipientSocketId).emit('message-received', {
            message: data.message,
            senderId: socket.userId,
            timestamp: new Date().toISOString()
          });
        }

        // Créer notification si destinataire hors ligne
        if (!recipientSocketId) {
          await this.createNotification(data.recipientId, {
            type: 'message',
            title: 'Nouveau message',
            message: `Vous avez reçu un nouveau message`,
            data: { messageId: data.message.id }
          });
        }
      });
    });

    console.log('🔌 WebSocket service initialized');
  }

  // Mettre à jour la présence utilisateur
  async updateUserPresence(userId, isOnline, socketId = null) {
    try {
      const client = await pool.connect();
      
      await client.query(`
        INSERT INTO user_presence (user_id, is_online, last_seen, socket_id)
        VALUES ($1, $2, CURRENT_TIMESTAMP, $3)
        ON CONFLICT (user_id)
        DO UPDATE SET 
          is_online = $2,
          last_seen = CURRENT_TIMESTAMP,
          socket_id = $3
      `, [userId, isOnline, socketId]);

      client.release();
    } catch (error) {
      console.error('Error updating presence:', error);
    }
  }

  // Récupérer la présence utilisateur
  async getUserPresence(userId) {
    try {
      const client = await pool.connect();
      
      const result = await client.query(
        'SELECT * FROM user_presence WHERE user_id = $1',
        [userId]
      );

      client.release();
      return result.rows[0];
    } catch (error) {
      console.error('Error getting presence:', error);
      return null;
    }
  }

  // Créer une notification
  async createNotification(userId, notification) {
    try {
      const client = await pool.connect();
      
      await client.query(`
        INSERT INTO notifications (user_id, type, title, message, data)
        VALUES ($1, $2, $3, $4, $5)
      `, [
        userId,
        notification.type,
        notification.title,
        notification.message,
        JSON.stringify(notification.data || {})
      ]);

      client.release();

      // Envoyer notification en temps réel si connecté
      const socketId = this.userSockets.get(userId);
      if (socketId) {
        this.io.to(socketId).emit('notification', notification);
      }
    } catch (error) {
      console.error('Error creating notification:', error);
    }
  }

  // Envoyer notification à un utilisateur
  sendNotificationToUser(userId, notification) {
    const socketId = this.userSockets.get(userId);
    if (socketId) {
      this.io.to(socketId).emit('notification', notification);
      return true;
    }
    return false;
  }

  // Vérifier si un utilisateur est en ligne
  isUserOnline(userId) {
    return this.userSockets.has(userId);
  }

  // Obtenir tous les utilisateurs en ligne
  getOnlineUsers() {
    return Array.from(this.userSockets.keys());
  }
}

// Singleton
const websocketService = new WebSocketService();

module.exports = websocketService;
