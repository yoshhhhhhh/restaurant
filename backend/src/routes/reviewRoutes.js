const express = require('express');
const reviewController = require('../controllers/reviewController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/:restaurantId', authMiddleware, reviewController.createReview);
router.get('/:restaurantId', reviewController.getRestaurantReviews);

module.exports = router;
