// src/routes/favorite.routes.js
const express = require('express');
const router = express.Router();
const favoriteController = require('../controllers/favorite.controller');
const authMiddleware = require('../middleware/auth.middleware');
const { requireAuthenticated } = require('../middleware/role.middleware');

// All routes require authentication
router.use(authMiddleware);

// Routes - tous les utilisateurs authentifiés peuvent gérer les favoris
router.get('/', requireAuthenticated, favoriteController.getUserFavorites);
router.post('/', requireAuthenticated, favoriteController.addFavorite);
router.delete('/:propertyId', requireAuthenticated, favoriteController.removeFavorite);

module.exports = router;
module.exports = router;
// src/routes/favorite.routes.js
const express = require('express');
const router = express.Router();
const favoriteController = require('../controllers/favorite.controller');
const authMiddleware = require('../middleware/auth.middleware');

// All routes require authentication
router.use(authMiddleware);

// Routes
router.get('/', favoriteController.getUserFavorites);
router.post('/', favoriteController.addFavorite);
router.delete('/:propertyId', favoriteController.removeFavorite);

module.exports = router;
