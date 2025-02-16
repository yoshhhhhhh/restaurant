#!/bin/bash

# Backend (Node.js)

# Create directories
mkdir -p backend/src
mkdir -p backend/src/routes
mkdir -p backend/tests
mkdir -p backend/src/controllers/
mkdir -p backend/src/middleware/
mkdir -p backend/src/models/

# Create backend files
cat > backend/src/app.js <<EOF
const express = require('express');
const bodyParser = require('body-parser');
const restaurantRoutes = require('./routes/restaurantRoutes');
const userRoutes = require('./routes/userRoutes');
const reviewRoutes = require('./routes/reviewRoutes');
const searchRoutes = require('./routes/searchRoutes');
const errorMiddleware = require('./middleware/errorMiddleware');

const app = express();
const port = process.env.PORT || 3001;

app.use(bodyParser.json());

// Routes
app.use('/api/restaurants', restaurantRoutes);
app.use('/api/users', userRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/search', searchRoutes);

// Error handling middleware
app.use(errorMiddleware);

app.listen(port, () => {
    console.log(\`Server is running on port \${port}\`);
});
EOF

cat > backend/src/routes/restaurantRoutes.js <<EOF
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
EOF

cat > backend/src/routes/userRoutes.js <<EOF
const express = require('express');
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/register', userController.registerUser);
router.post('/login', userController.loginUser);
router.get('/profile', authMiddleware, userController.getUserProfile);
router.put('/profile', authMiddleware, userController.updateUserProfile);

module.exports = router;
EOF

cat > backend/src/routes/reviewRoutes.js <<EOF
const express = require('express');
const reviewController = require('../controllers/reviewController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/:restaurantId', authMiddleware, reviewController.createReview);
router.get('/:restaurantId', reviewController.getRestaurantReviews);

module.exports = router;
EOF

cat > backend/src/routes/searchRoutes.js <<EOF
const express = require('express');
const searchController = require('../controllers/searchController');

const router = express.Router();

router.get('/', searchController.searchRestaurants);

module.exports = router;
EOF

cat > backend/src/controllers/restaurantController.js <<EOF
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
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { cuisine: { $regex: query, $options: 'i' } },
      ],
    });
    res.status(200).json(restaurants);
  } catch (error) {
    res.status(500).json({ message: 'Error searching restaurants', error: error.message });
  }
};
EOF

cat > backend/src/controllers/userController.js <<EOF
const User = require('../models/User');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { validationResult } = require('express-validator');

// Register User
exports.registerUser = async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    try {
        const hashedPassword = await bcrypt.hash(req.body.password, 10);
        const user = new User({
            ...req.body,
            password: hashedPassword
        });
        await user.save();
        res.status(201).json({ message: 'User registered successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error registering user', error: error.message });
    }
};

// Login User
exports.loginUser = async (req, res) => {
    try {
        const user = await User.findOne({ email: req.body.email });
        if (!user) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        const passwordMatch = await bcrypt.compare(req.body.password, user.password);
        if (!passwordMatch) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        const token = jwt.sign({ userId: user._id }, 'your-secret-key', { expiresIn: '1h' });
        res.status(200).json({ message: 'Login successful', token: token });
    } catch (error) {
        res.status(500).json({ message: 'Error logging in', error: error.message });
    }
};

// Get User Profile (requires authentication)
exports.getUserProfile = async (req, res) => {
    try {
        const user = await User.findById(req.userId).select('-password');
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.status(200).json(user);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching user profile', error: error.message });
    }
};

// Update User Profile (requires authentication)
exports.updateUserProfile = async (req, res) => {
    try {
        const user = await User.findByIdAndUpdate(req.userId, req.body, { new: true }).select('-password');
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.status(200).json(user);
    } catch (error) {
        res.status(500).json({ message: 'Error updating user profile', error: error.message });
    }
};
EOF

cat > backend/src/controllers/reviewController.js <<EOF
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
EOF

cat > backend/src/controllers/searchController.js <<EOF
const Restaurant = require('../models/Restaurant');

// Search Restaurants
exports.searchRestaurants = async (req, res) => {
  const { query } = req.query;

  try {
    const restaurants = await Restaurant.find({
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { cuisine: { $regex: query, $options: 'i' } },
      ],
    });
    res.status(200).json(restaurants);
  } catch (error) {
    res.status(500).json({ message: 'Error searching restaurants', error: error.message });
  }
};
EOF

cat > backend/src/middleware/authMiddleware.js <<EOF
const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
    try {
        const token = req.headers.authorization.split(' ')[1];
        const decodedToken = jwt.verify(token, 'your-secret-key');
        req.userId = decodedToken.userId;
        next();
    } catch (error) {
        res.status(401).json({ message: 'Authentication failed' });
    }
};
EOF

cat > backend/src/middleware/errorMiddleware.js <<EOF
module.exports = (err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
};
EOF

cat > backend/src/models/Restaurant.js <<EOF
const mongoose = require('mongoose');

const restaurantSchema = new mongoose.Schema({
    name: { type: String, required: true },
    address: { type: String, required: true },
    cuisine: { type: String },
    operatingHours: { type: String },
    contactDetails: { type: String },
    menu: [{
        name: { type: String, required: true },
        description: { type: String },
        price: { type: Number, required: true }
    }],
    averageRating: { type: Number, default: 0 },
    isOpen: {type: Boolean, default: true} // Add isOpen field
});

module.exports = mongoose.model('Restaurant', restaurantSchema);
EOF

cat > backend/src/models/User.js <<EOF
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    username: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    deliveryAddress: { type: String }
});

module.exports = mongoose.model('User', userSchema);
EOF

cat > backend/src/models/Review.js <<EOF
const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
    restaurantId: { type: mongoose.Schema.Types.ObjectId, ref: 'Restaurant', required: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    rating: { type: Number, required: true, min: 1, max: 5 },
    comment: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Review', reviewSchema);
EOF

cat > backend/tests/restaurant.test.js <<EOF
const request = require('supertest');
const app = require('../src/app'); // Assuming your main app file is app.js
const mongoose = require('mongoose');
const Restaurant = require('../src/models/Restaurant');

describe('Restaurant API Endpoints', () => {
  beforeAll(async () => {
    // Connect to a test database (replace with your test DB URL)
    await mongoose.connect('mongodb://localhost:27017/testdb', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
  });

  afterAll(async () => {
    // Close the connection after all tests
    await mongoose.connection.close();
  });

  beforeEach(async () => {
    // Clear the database before each test
    await Restaurant.deleteMany({});
  });

  it('should create a new restaurant', async () => {
    const restaurantData = {
      name: 'Test Restaurant',
      address: '123 Test Street',
      cuisine: 'Test Cuisine',
      operatingHours: '9am - 5pm',
      contactDetails: 'test@example.com',
    };

    const response = await request(app)
      .post('/api/restaurants')
      .send(restaurantData)
      .set('Authorization', 'Bearer fake-token'); // Replace with your auth setup

    expect(response.statusCode).toBe(201);
    expect(response.body.name).toBe(restaurantData.name);
  });

  it('should get a restaurant by ID', async () => {
    const restaurant = new Restaurant({
      name: 'Test Restaurant',
      address: '123 Test Street',
      cuisine: 'Test Cuisine',
      operatingHours: '9am - 5pm',
      contactDetails: 'test@example.com',
    });
    await restaurant.save();

    const response = await request(app).get(\`/api/restaurants/\${restaurant._id}\`);

    expect(response.statusCode).toBe(200);
    expect(response.body.name).toBe(restaurant.name);
  });
});
EOF


# Frontend (React.js)

# Create directories
mkdir -p frontend/src/components
mkdir -p frontend/src/pages

# Create frontend files
cat > frontend/src/App.js <<EOF
import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import HomePage from './pages/HomePage';
import RestaurantList from './pages/RestaurantList';
import RestaurantProfile from './pages/RestaurantProfile';
import LoginPage from './pages/LoginPage';
import SignupPage from './pages/SignupPage';
import UserProfile from './pages/UserProfile';
import ReviewForm from './components/ReviewForm';
import SearchBar from './components/SearchBar';
import Navigation from './components/Navigation';
import './App.css';

function App() {
  return (
    <Router>
      <Navigation />
      <div className="container">
        <Switch>
          <Route path="/" exact component={HomePage} />
          <Route path="/restaurants" exact component={RestaurantList} />
          <Route path="/restaurants/:id" component={RestaurantProfile} />
          <Route path="/login" component={LoginPage} />
          <Route path="/signup" component={SignupPage} />
          <Route path="/profile" component={UserProfile} />
          <Route path="/review/:restaurantId" component={ReviewForm} />
          <Route path="/search" component={SearchBar} />
        </Switch>
      </div>
    </Router>
  );
}

export default App;
EOF

cat > frontend/src/components/RestaurantCard.js <<EOF
import React from 'react';
import { Link } from 'react-router-dom';

function RestaurantCard({ restaurant }) {
  return (
    <div className="restaurant-card">
      <h3>{restaurant.name}</h3>
      <p>{restaurant.cuisine}</p>
      <p>Rating: {restaurant.averageRating}</p>
      <Link to={\`/restaurants/\${restaurant._id}\`}>View Details</Link>
    </div>
  );
}

export default RestaurantCard;
EOF

cat > frontend/src/components/ReviewForm.js <<EOF
import React, { useState } from 'react';

function ReviewForm({ restaurantId }) {
  const [rating, setRating] = useState(5);
  const [comment, setComment] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    // Implement API call to submit review
    console.log('Submitting review:', { restaurantId, rating, comment });
    // Reset form
    setRating(5);
    setComment('');
  };

  return (
    <div className="review-form">
      <h2>Submit a Review</h2>
      <form onSubmit={handleSubmit}>
        <div>
          <label htmlFor="rating">Rating:</label>
          <select id="rating" value={rating} onChange={(e) => setRating(parseInt(e.target.value))}>
            <option value="1">1 Star</option>
            <option value="2">2 Stars</option>
            <option value="3">3 Stars</option>
            <option value="4">4 Stars</option>
            <option value="5">5 Stars</option>
          </select>
        </div>
        <div>
          <label htmlFor="comment">Comment:</label>
          <textarea id="comment" value={comment} onChange={(e) => setComment(e.target.value)} />
        </div>
        <button type="submit">Submit Review</button>
      </form>
    </div>
  );
}

export default ReviewForm;
EOF

cat > frontend/src/components/SearchBar.js <<EOF
import React, { useState } from 'react';

function SearchBar({ onSearch }) {
  const [searchTerm, setSearchTerm] = useState('');

  const handleChange = (e) => {
    setSearchTerm(e.target.value);
    onSearch(e.target.value); // Call the onSearch function to update restaurant list
  };

  return (
    <div className="search-bar">
      <input
        type="text"
        placeholder="Search restaurants..."
        value={searchTerm}
        onChange={handleChange}
      />
    </div>
  );
}

export default SearchBar;
EOF

cat > frontend/src/components/Navigation.js <<EOF
import React from 'react';
import { Link } from 'react-router-dom';

function Navigation() {
  return (
    <nav className="navigation">
      <ul>
        <li>
          <Link to="/">Home</Link>
        </li>
        <li>
          <Link to="/restaurants">Restaurants</Link>
        </li>
        <li>
          <Link to="/search">Search</Link>
        </li>
        <li>
          <Link to="/login">Login</Link>
        </li>
        <li>
          <Link to="/signup">Signup</Link>
        </li>
        <li>
          <Link to="/profile">Profile</Link>
        </li>
      </ul>
    </nav>
  );
}

export default Navigation;
EOF

cat > frontend/src/pages/HomePage.js <<EOF
import React from 'react';

function HomePage() {
  return (
    <div className="home-page">
      <h1>Welcome to Our Food Delivery App!</h1>
      <p>Find your favorite restaurants and order delicious food online.</p>
    </div>
  );
}

export default HomePage;
EOF

cat > frontend/src/pages/RestaurantList.js <<EOF
import React, { useState, useEffect } from 'react';
import RestaurantCard from '../components/RestaurantCard';

function RestaurantList() {
  const [restaurants, setRestaurants] = useState([]);

  useEffect(() => {
    // Implement API call to fetch restaurant list
    const fetchRestaurants = async () => {
      // Example: const response = await fetch('/api/restaurants');
      // const data = await response.json();
      // setRestaurants(data);

      // Dummy data for demonstration purposes
      const dummyData = [
        { _id: '1', name: 'Restaurant A', cuisine: 'Italian', averageRating: 4.5 },
        { _id: '2', name: 'Restaurant B', cuisine: 'Mexican', averageRating: 4.2 },
      ];
      setRestaurants(dummyData);
    };

    fetchRestaurants();
  }, []);

  return (
    <div className="restaurant-list">
      <h2>Our Restaurants</h2>
      {restaurants.map(restaurant => (
        <RestaurantCard key={restaurant._id} restaurant={restaurant} />
      ))}
    </div>
  );
}

export default RestaurantList;
EOF

cat > frontend/src/pages/RestaurantProfile.js <<EOF
import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';

function RestaurantProfile() {
  const { id } = useParams();
  const [restaurant, setRestaurant] = useState(null);

  useEffect(() => {
    // Implement API call to fetch restaurant details by ID
    const fetchRestaurant = async () => {
      // Example: const response = await fetch(\`/api/restaurants/\${id}\`);
      // const data = await response.json();
      // setRestaurant(data);

      // Dummy data for demonstration purposes
      const dummyRestaurant = {
        _id: id,
        name: 'Restaurant XYZ',
        cuisine: 'Indian',
        address: '456 Example Street',
        operatingHours: '11am - 10pm',
        menu: [
          { name: 'Butter Chicken', price: 15.99 },
          { name: 'Chicken Tikka Masala', price: 16.99 },
        ],
      };
      setRestaurant(dummyRestaurant);
    };

    fetchRestaurant();
  }, [id]);

  if (!restaurant) {
    return <div>Loading...</div>;
  }

  return (
    <div className="restaurant-profile">
      <h2>{restaurant.name}</h2>
      <p>Cuisine: {restaurant.cuisine}</p>
      <p>Address: {restaurant.address}</p>
      <p>Operating Hours: {restaurant.operatingHours}</p>
      <h3>Menu</h3>
      <ul>
        {restaurant.menu.map(item => (
          <li key={item.name}>
            {item.name} - \${item.price}
          </li>
        ))}
      </ul>
      <Link to={\`/review/\${restaurant._id}\`}>Write a Review</Link>
    </div>
  );
}

export default RestaurantProfile;
EOF

cat > frontend/src/pages/LoginPage.js <<EOF
import React, { useState } from 'react';

function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    // Implement API call for login
    console.log('Logging in with:', { email, password });
    // Handle successful login (e.g., store token)
  };

  return (
    <div className="login-page">
      <h2>Login</h2>
      <form onSubmit={handleSubmit}>
        <div>
          <label htmlFor="email">Email:</label>
          <input
            type="email"
            id="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>
        <div>
          <label htmlFor="password">Password:</label>
          <input
            type="password"
            id="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>
        <button type="submit">Login</button>
      </form>
    </div>
  );
}

export default LoginPage;
EOF

cat > frontend/src/pages/SignupPage.js <<EOF
import React, { useState } from 'react';

function SignupPage() {
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    // Implement API call for signup
    console.log('Signing up with:', { username, email, password });
    // Handle successful signup
  };

  return (
    <div className="signup-page">
      <h2>Signup</h2>
      <form onSubmit={handleSubmit}>
        <div>
          <label htmlFor="username">Username:</label>
          <input
            type="text"
            id="username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
          />
        </div>
        <div>
          <label htmlFor="email">Email:</label>
          <input
            type="email"
            id="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>
        <div>
          <label htmlFor="password">Password:</label>
          <input
            type="password"
            id="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>
        <button type="submit">Signup</button>
      </form>
    </div>
  );
}

export default SignupPage;
EOF

cat > frontend/src/pages/UserProfile.js <<EOF
import React, { useState, useEffect } from 'react';

function UserProfile() {
  const [profile, setProfile] = useState({
    username: '',
    email: '',
    deliveryAddress: '',
  });

  useEffect(() => {
    // Implement API call to fetch user profile data
    const fetchProfile = async () => {
      // Example: const response = await fetch('/api/users/profile');
      // const data = await response.json();
      // setProfile(data);

      // Dummy data for demonstration purposes
      const dummyData = {
        username: 'testuser',
        email: 'test@example.com',
        deliveryAddress: '123 Test Street',
      };
      setProfile(dummyData);
    };

    fetchProfile();
  }, []);

  const handleChange = (e) => {
    setProfile({ ...profile, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    // Implement API call to update user profile
    console.log('Updating profile:', profile);
    // Handle successful update
  };

  return (
    <div className="user-profile">
      <h2>User Profile</h2>
      <form onSubmit={handleSubmit}>
        <div>
          <label htmlFor="username">Username:</label>
          <input
            type="text"
            id="username"
            name="username"
            value={profile.username}
            onChange={handleChange}
          />
        </div>
        <div>
          <label htmlFor="email">Email:</label>
          <input
            type="email"
            id="email"
            name="email"
            value={profile.email}
            onChange={handleChange}
          />
        </div>
        <div>
          <label htmlFor="deliveryAddress">Delivery Address:</label>
          <input
            type="text"
            id="deliveryAddress"
            name="deliveryAddress"
            value={profile.deliveryAddress}
            onChange={handleChange}
          />
        </div>
        <button type="submit">Update Profile</button>
      </form>
    </div>
  );
}

export default UserProfile;
EOF

cat > frontend/src/App.css <<EOF
.container {
    max-width: 960px;
    margin: 20px auto;
    padding: 20px;
    border: 1px solid #ddd;
    border-radius: 8px;
}

.restaurant-card {
    border: 1px solid #eee;
    padding: 10px;
    margin-bottom: 10px;
    border-radius: 4px;
    background-color: #f9f9f9;
}

.restaurant-card h3 {
    margin-top: 0;
}

.review-form {
    padding: 20px;
    border: 1px solid #ddd;
    border-radius: 8px;
    margin-top: 20px;
}

.review-form label {
    display: block;
    margin-bottom: 5px;
    font-weight: bold;
}

.review-form textarea,
.review-form select {
    width: 100%;
    padding: 8px;
    margin-bottom: 10px;
    border: 1px solid #ccc;
    border-radius: 4px;
    box-sizing: border-box;
}

.search-bar {
    margin-bottom: 20px;
}

.search-bar input[type="text"] {
    width: 100%;
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 4px;
    box-sizing: border-box;
}

.navigation {
    background-color: #333;
    color: white;
    padding: 10px 0;
    margin-bottom: 20px;
}

.navigation ul {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    justify-content: space-around;
}

.navigation ul li a {
    color: white;
    text-decoration: none;
    padding: 8px 16px;
    border-radius: 4px;
    transition: background-color 0.3s;
}

.navigation ul li a:hover {
    background-color: #555;
}
/* Add more CSS rules here */
EOF

# Database Design (MySQL)
# The following commands are for illustrative purposes.  You'd execute these
# in your MySQL client.  This script *creates* the commands, it doesn't run them.

cat > database_schema.sql <<EOF
-- Database Schema for Food Delivery App

-- Drop tables if they exist (for development/testing purposes)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS menu_items;
DROP TABLE IF EXISTS menus;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS delivery_drivers;

-- Users Table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    delivery_address TEXT
);

-- Restaurants Table
CREATE TABLE restaurants (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    cuisine VARCHAR(255),
    operating_hours VARCHAR(255),
    contact_details VARCHAR(255),
    average_rating DECIMAL(2,1) DEFAULT 0.0,
    is_open BOOLEAN DEFAULT TRUE
);

-- Menus Table
CREATE TABLE menus (
    menu_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT,
    name VARCHAR(255) NOT NULL,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

-- Menu Items Table
CREATE TABLE menu_items (
    menu_item_id INT AUTO_INCREMENT PRIMARY KEY,
    menu_id INT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (menu_id) REFERENCES menus(menu_id)
);

-- Orders Table
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_cost DECIMAL(10, 2) NOT NULL,
    delivery_address TEXT,
    order_status ENUM('pending', 'preparing', 'out_for_delivery', 'delivered', 'cancelled') DEFAULT 'pending',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Order Items Table
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    menu_item_id INT,
    quantity INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(menu_item_id)
);

-- Delivery Drivers Table
CREATE TABLE delivery_drivers (
    driver_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    availability_status ENUM('available', 'busy', 'offline') DEFAULT 'available',
    current_location POINT,
    order_id INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Stored Procedures

-- Get total revenue for a restaurant
DELIMITER //
CREATE PROCEDURE GetRestaurantRevenue(IN restaurantID INT)
BEGIN
    SELECT SUM(o.total_cost) AS total_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id
    JOIN menus m ON mi.menu_id = m.menu_id
    WHERE m.restaurant_id = restaurantID;
END //
DELIMITER ;

-- Get average order value for a user
DELIMITER //
CREATE PROCEDURE GetUserAvgOrderValue(IN userID INT)
BEGIN
    SELECT AVG(total_cost) AS average_order_value
    FROM orders
    WHERE user_id = userID;
END //
DELIMITER ;

-- Indexes for performance
CREATE INDEX idx_restaurant_name ON restaurants (name);
CREATE INDEX idx_menu_item_name ON menu_items (name);
CREATE INDEX idx_order_user_id ON orders (user_id);

-- Example Queries
-- Get all restaurants
SELECT * FROM restaurants;

-- Get menu items for a specific restaurant
SELECT mi.*
FROM menu_items mi
JOIN menus m ON mi.menu_id = m.menu_id
WHERE m.restaurant_id = 1;

-- Get all orders for a specific user
SELECT * FROM orders WHERE user_id = 1;

-- Get all items in a specific order
SELECT mi.*, oi.quantity
FROM order_items oi
JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id
WHERE oi.order_id = 1;

-- Sample Data (for demonstration - replace with your actual data)
INSERT INTO users (username, email, password, delivery_address) VALUES
('johndoe', 'john.doe@example.com', 'password123', '123 Main St'),
('janesmith', 'jane.smith@example.com', 'securepass', '456 Oak Ave');

INSERT INTO restaurants (name, address, cuisine, operating_hours, contact_details) VALUES
('Pizza Palace', '789 Pine Ln', 'Italian', '11:00 AM - 10:00 PM', '555-1234'),
('Taco Time', '321 Elm St', 'Mexican', '10:00 AM - 9:00 PM', '555-5678');

INSERT INTO menus (restaurant_id, name) VALUES
(1, 'Main Menu'),
(2, 'Lunch Menu');

INSERT INTO menu_items (menu_id, name, description, price) VALUES
(1, 'Margherita Pizza', 'Classic tomato and mozzarella pizza', 12.99),
(1, 'Pepperoni Pizza', 'Pizza with pepperoni', 14.99),
(2, 'Tacos', 'Assorted tacos', 8.99),
(2, 'Burrito', 'Large burrito with your choice of fillings', 9.99);

INSERT INTO orders (user_id, total_cost, delivery_address) VALUES
(1, 27.98, '123 Main St'),
(2, 18.98, '456 Oak Ave');

INSERT INTO order_items (order_id, menu_item_id, quantity) VALUES
(1, 1, 1),
(1, 2, 1),
(2, 3, 2);
EOF

# API Design (Example - Adapt to your specific needs and frameworks)
# These are descriptive examples. The actual implementation would be in your Node.js backend.

cat > api_endpoints.txt <<EOF
# API Endpoints

## Restaurants

*   **POST /api/restaurants** - Create a new restaurant (requires authentication - admin role)
    *   Request body: JSON object containing restaurant details (name, address, cuisine, operating_hours, contact_details, menu)
    *   Response:
        *   201 Created: Restaurant created successfully.  Returns the created restaurant object.
        *   400 Bad Request: Invalid request data.
        *   401 Unauthorized: User not authenticated or lacks admin privileges.
        *   500 Internal Server Error: Server error.

*   **GET /api/restaurants/{restaurantId}** - Get a restaurant by ID
    *   Response:
        *   200 OK: Restaurant found.  Returns the restaurant object.
        *   404 Not Found: Restaurant not found.
        *   500 Internal Server Error: Server error.

*   **PUT /api/restaurants/{restaurantId}** - Update a restaurant (requires authentication - admin or restaurant owner)
    *   Request body: JSON object containing updated restaurant details.
    *   Response:
        *   200 OK: Restaurant updated successfully.  Returns the updated restaurant object.
        *   400 Bad Request: Invalid request data.
        *   401 Unauthorized: User not authenticated or lacks privileges.
        *   404 Not Found: Restaurant not found.
        *   500 Internal Server Error: Server error.

*   **DELETE /api/restaurants/{restaurantId}** - Delete a restaurant (mark as closed) (requires authentication - admin or restaurant owner)
    *   Response:
        *   200 OK: Restaurant marked as closed.
        *   401 Unauthorized: User not authenticated or lacks privileges.
        *   404 Not Found: Restaurant not found.
        *   500 Internal Server Error: Server error.

*   **GET /api/restaurants/nearby?latitude={latitude}&longitude={longitude}&radius={radius}** - Get nearby restaurants (requires geo-location support in database)
    *   Parameters:
        *   latitude: User's latitude.
        *   longitude: User's longitude.
        *   radius: Search radius in kilometers.
    *   Response:
        *   200 OK: Returns a list of nearby restaurant objects.
        *   400 Bad Request: Invalid request data.
        *   500 Internal Server Error: Server error.

*   **GET /api/restaurants/search?q={query}** - Search for restaurants by name or cuisine
    *   Parameters:
        *   q: Search query.
    *   Response:
        *   200 OK: Returns a list of matching restaurant objects.
        *   500 Internal Server Error: Server error.

## Menus

*   **GET /api/restaurants/{restaurantId}/menus** - Get all menus for a restaurant
    *   Response:
        *   200 OK: Returns a list of menu objects.
        *   404 Not Found: Restaurant not found.
        *   500 Internal Server Error: Server error.

*   **POST /api/restaurants/{restaurantId}/menus** - Create a new menu for a restaurant (requires authentication)
    *   Request body: JSON object containing menu details.
    *   Response:
        *   201 Created: Menu created successfully.
        *   400 Bad Request: Invalid request data.
        *   401 Unauthorized: User not authenticated.
        *   404 Not Found: Restaurant not found.
        *   500 Internal Server Error: Server error.

## Menu Items

*   **GET /api/menus/{menuId}/items** - Get all menu items for a menu
    *   Response:
        *   200 OK: Returns a list of menu item objects.
        *   404 Not Found: Menu not found.
        *   500 Internal Server Error: Server error.

*   **POST /api/menus/{menuId}/items** - Create a new menu item for a menu (requires authentication)
    *   Request body: JSON object containing menu item details.
    *   Response:
        *   201 Created: Menu item created successfully.
        *   400 Bad Request: Invalid request data.
        *   401 Unauthorized: User not authenticated.
        *   404 Not Found: Menu not found.
        *   500 Internal Server Error: Server error.

## Users

*   **POST /api/users/register** - Register a new user
    *   Request body: JSON object containing user details (username, email, password, delivery_address)
    *   Response:
        *   201 Created: User registered successfully.
        *   400 Bad Request: Invalid request data (e.g., email already exists).
        *   500 Internal Server Error: Server error.

*   **POST /api/users/login** - Login a user
    *   Request body: JSON object containing email and password
    *   Response:
        *   200 OK: Login successful.  Returns a JWT token.
        *   400 Bad Request: Invalid credentials.
        *   500 Internal Server Error: Server error.

*   **GET /api/users/profile** - Get the logged-in user's profile (requires authentication)
    *   Response:
        *   200 OK: Returns the user profile object.
        *   401 Unauthorized: User not authenticated.
        *   404 Not Found: User not found.
        *   500 Internal Server Error: Server error.

*   **PUT /api/users/profile** - Update the logged-in user's profile (requires authentication)
    *   Request body: JSON object containing updated user details.
    *   Response:
        *   200 OK: User profile updated successfully.  Returns the updated user profile object.
        *   400 Bad Request: Invalid request data.
        *   401 Unauthorized: User not authenticated.
        *   404 Not Found: User not found.
        *   500 Internal Server Error: Server error.

## Orders

*   **POST /api/orders** - Create a new order (requires authentication)
    *   Request body: JSON object containing order details (user_id, items, delivery_address).  Items should be an array of {menu_item_id, quantity} objects.
    *   Response:
        *   201 Created: Order created successfully.
        *   400 Bad Request: Invalid request data.
        *   401 Unauthorized: User not authenticated.
        *   500 Internal Server Error: Server error.

*   **GET /api/orders/{orderId}** - Get an order by ID (requires authentication - user can only access their own orders, admin can access all)
    *   Response:
        *   200 OK: Order found. Returns the order object.
        *   401 Unauthorized: User not authenticated or lacks privileges.
        *   404 Not Found: Order not found.
        *   500 Internal Server Error: Server error.

*   **PUT /api/orders/{orderId}** - Update order status (requires authentication - admin or restaurant)
    * Request body: JSON Object containing order_status
    *   Response:
        *   200 OK: Order updated.
        *   401 Unauthorized: User not authenticated or lacks privileges.
        *   404 Not Found: Order not found.
        *   500 Internal Server Error: Server error.

## Reviews

*   **POST /api/restaurants/{restaurantId}/reviews** - Add a review to a restaurant (requires authentication)
    *   Request body: JSON Object containing rating, comment
    *   Response:
        *   200 OK: Review Added.
        *   401 Unauthorized: User not authenticated or lacks privileges.
        *   404 Not Found: Restaurant not found.
        *   500 Internal Server Error: Server error.

*   **GET /api/restaurants/{restaurantId}/reviews** - Get reviews for a restaurant
    * Response:
        *   200 OK: List of reviews returned.
        *   404 Not Found: Restaurant not found.
        *   500 Internal Server Error: Server error.

# Data Validation (Example using express-validator in Node.js)

# Example of validating the create restaurant endpoint

cat > backend/src/validators/restaurantValidator.js <<EOF
const { body } = require('express-validator');

exports.createRestaurantValidator = [
    body('name').notEmpty().withMessage('Name is required'),
    body('address').notEmpty().withMessage('Address is required'),
    body('cuisine').optional(),
    body('operatingHours').optional(),
    body('contactDetails').optional()
];
EOF

# And in your restaurantRoutes.js:

#const { createRestaurantValidator } = require('../validators/restaurantValidator');

#router.post('/', createRestaurantValidator, restaurantController.createRestaurant);

# Helper Scripts

cat > .gitignore <<EOF
node_modules/
/backend/node_modules
/frontend/node_modules
EOF

echo "Project structure created.  Remember to install dependencies (e.g., npm install) in the backend and frontend directories."
