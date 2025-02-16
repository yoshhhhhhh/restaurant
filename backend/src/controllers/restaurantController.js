const Restaurant = require('../models/Restaurant');
const { validationResult } = require('express-validator');

// Create Restaurant
exports.createRestaurant = async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    try {
        const restaurant = new Restaurant(req.body);
        await restaurant.save();
        res.status(201).json(restaurant);
    } catch (error) {
        res.status(500).json({ message: 'Error creating restaurant', error: error.message });
    }
};

// Get Restaurant by ID
exports.getRestaurant = async (req, res) => {
    try {
        const restaurant = await Restaurant.findById(req.params.id);
        if (!restaurant) {
            return res.status(404).json({ message: 'Restaurant not found' });
        }
        res.status(200).json(restaurant);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching restaurant', error: error.message });
    }
};

// Update Restaurant
exports.updateRestaurant = async (req, res) => {
    try {
        const restaurant = await Restaurant.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!restaurant) {
            return res.status(404).json({ message: 'Restaurant not found' });
        }
        res.status(200).json(restaurant);
    } catch (error) {
        res.status(500).json({ message: 'Error updating restaurant', error: error.message });
    }
};

// Delete Restaurant (Mark as closed)
exports.deleteRestaurant = async (req, res) => {
  try {
    const restaurant = await Restaurant.findByIdAndUpdate(req.params.id, { isOpen: false }, { new: true });
    if (!restaurant) {
      return res.status(404).json({ message: 'Restaurant not found' });
    }
    res.status(200).json({ message: 'Restaurant marked as closed' });
  } catch (error) {
    res.status(500).json({ message: 'Error closing restaurant', error: error.message });
  }
};

// Get Nearby Restaurants (Example - replace with geo-location based query)
exports.getNearbyRestaurants = async (req, res) => {
  try {
    // Implement logic to fetch restaurants within a radius
    const restaurants = await Restaurant.find({/* your query here based on location data */});
    res.status(200).json(restaurants);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching nearby restaurants', error: error.message });
  }
};

// Search Restaurants
exports.searchRestaurants = async (req, res) => {
  const { query } = req.query;

  try {
    // Implement search logic (e.g., using regex)
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
