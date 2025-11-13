// src/routes/upload.routes.js
const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/upload.controller');
const authMiddleware = require('../middleware/auth.middleware');
const upload = require('../config/multer');

// Routes
router.post('/', authMiddleware, upload.single('image'), uploadController.uploadImage);
router.post('/multiple', authMiddleware, upload.array('images', 10), uploadController.uploadMultipleImages);

module.exports = router;
// src/routes/upload.routes.js
const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/upload.controller');
const authMiddleware = require('../middleware/auth.middleware');
const upload = require('../config/multer');

// Routes
router.post('/', authMiddleware, upload.single('image'), uploadController.uploadImage);
router.post('/multiple', authMiddleware, upload.array('images', 10), uploadController.uploadMultipleImages);

module.exports = router;
