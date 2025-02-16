const express = require('express');
const restaurantController = require('../controllers/restaurantController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/', authMiddleware, restaurantController.createRestaurant);
router.get('/:id', restaurantController.getRestaurant);
router.put('/:id', authMiddleware, restaurantController.updateRestaurant);
router.delete('/:id', authMiddleware, restaurantController.deleteRestaurant);
router.get('/', restaurantController.getNearbyRestaurants); // Get nearby restaurants
router.get('/search', restaurantController.searchRestaurants); // Search restaurants

module.exports = router;
