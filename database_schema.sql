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
