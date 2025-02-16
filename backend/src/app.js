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
    console.log(`Server is running on port ${port}`);
});
