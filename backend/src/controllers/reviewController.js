const Review = require('../models/Review');

// Create Review
exports.createReview = async (req, res) => {
    try {
        const review = new Review({
            ...req.body,
            restaurantId: req.params.restaurantId,
            userId: req.userId
        });
        await review.save();
        res.status(201).json(review);
    } catch (error) {
        res.status(500).json({ message: 'Error creating review', error: error.message });
    }
};

// Get Restaurant Reviews
exports.getRestaurantReviews = async (req, res) => {
    try {
        const reviews = await Review.find({ restaurantId: req.params.restaurantId }).populate('userId', 'username'); // Populate user details
        res.status(200).json(reviews);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching reviews', error: error.message });
    }
};
