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
