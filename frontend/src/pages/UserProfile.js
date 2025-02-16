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
