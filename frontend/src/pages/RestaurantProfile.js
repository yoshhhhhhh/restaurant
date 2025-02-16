import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';

function RestaurantProfile() {
  const { id } = useParams();
  const [restaurant, setRestaurant] = useState(null);

  useEffect(() => {
    // Implement API call to fetch restaurant details by ID
    const fetchRestaurant = async () => {
      // Example: const response = await fetch(`/api/restaurants/${id}`);
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
            {item.name} - ${item.price}
          </li>
        ))}
      </ul>
      <Link to={`/review/${restaurant._id}`}>Write a Review</Link>
    </div>
  );
}

export default RestaurantProfile;
