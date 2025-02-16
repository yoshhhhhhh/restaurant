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

    const response = await request(app).get(`/api/restaurants/${restaurant._id}`);

    expect(response.statusCode).toBe(200);
    expect(response.body.name).toBe(restaurant.name);
  });
});
