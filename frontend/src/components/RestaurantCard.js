import React from 'react';
import { Link } from 'react-router-dom';

function RestaurantCard({ restaurant }) {
  return (
    <div className="restaurant-card">
      <h3>{restaurant.name}</h3>
      <p>{restaurant.cuisine}</p>
      <p>Rating: {restaurant.averageRating}</p>
      <Link to={`/restaurants/${restaurant._id}`}>View Details</Link>
    </div>
  );
}

export default RestaurantCard;
