const Restaurant = require('../models/Restaurant');

// Search Restaurants
exports.searchRestaurants = async (req, res) => {
  const { query } = req.query;

  try {
    const restaurants = await Restaurant.find({
      : [
        { name: { : query, : 'i' } },
        { cuisine: { : query, : 'i' } },
      ],
    });
    res.status(200).json(restaurants);
  } catch (error) {
    res.status(500).json({ message: 'Error searching restaurants', error: error.message });
  }
};
