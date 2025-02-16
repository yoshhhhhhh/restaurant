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
