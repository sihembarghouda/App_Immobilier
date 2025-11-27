require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const path = require('path');

// Verify critical env variables at startup
console.log('🔐 JWT_SECRET loaded:', process.env.JWT_SECRET ? `${process.env.JWT_SECRET.substring(0, 10)}... (${process.env.JWT_SECRET.length} chars)` : '❌ MISSING');
console.log('⏰ JWT_EXPIRES_IN:', process.env.JWT_EXPIRES_IN || '7d (default)');
console.log('🌐 CORS_ORIGIN:', process.env.CORS_ORIGIN || '* (all origins)');

// Import routes
const authRoutes = require('./src/routes/auth.routes');
const propertyRoutes = require('./src/routes/property.routes');
const favoriteRoutes = require('./src/routes/favorite.routes');
const messageRoutes = require('./src/routes/message.routes');
const uploadRoutes = require('./src/routes/upload.routes');
const aiRoutes = require('./src/routes/ai.routes');
const securityRoutes = require('./src/routes/security.routes');
const notificationRoutes = require('./src/routes/notification.routes');

// Import database
const pool = require('./src/config/database');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" },
  crossOriginEmbedderPolicy: false
})); // Security headers
app.use(cors({
  origin: true, // Allow all origins in development
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  exposedHeaders: ['Authorization']
}));
// Handle CORS preflight for all routes
app.options('*', cors());
app.use(morgan('dev')); // Logging
app.use(compression()); // Compress responses
app.use(express.json({ limit: '50mb' })); // Parse JSON bodies with 50MB limit
app.use(express.urlencoded({ extended: true, limit: '50mb' })); // Parse URL-encoded bodies

// Serve static files (uploaded images)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    message: 'Server is running',
    timestamp: new Date().toISOString()
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/properties', propertyRoutes);
app.use('/api/favorites', favoriteRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/security', securityRoutes);
app.use('/api/notifications', notificationRoutes);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ 
    success: false, 
    message: 'Route not found' 
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';
  
  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Test database connection and start server
pool.query('SELECT NOW()', (err, result) => {
  if (err) {
    console.error('❌ Database connection failed:', err.message);
    console.log('⚠️  Server starting without database connection...');
  } else {
    console.log('✅ Database connected successfully');
  }

  const server = app.listen(PORT, () => {
    console.log(`🚀 Server is running on port ${PORT}`);
    console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`🌐 API Base URL: http://localhost:${PORT}/api`);
    
    // Initialize WebSocket after server starts
    const websocketService = require('./src/services/websocket.service');
    websocketService.initialize(server);
  });
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  pool.end(() => {
    console.log('Database pool closed');
    process.exit(0);
  });
});

// Extra diagnostics to avoid silent exits
process.on('unhandledRejection', (reason) => {
  console.error('🔴 Unhandled Rejection:', reason);
});

process.on('uncaughtException', (err) => {
  console.error('🔴 Uncaught Exception:', err);
});

module.exports = app;