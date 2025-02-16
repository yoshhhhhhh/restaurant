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
