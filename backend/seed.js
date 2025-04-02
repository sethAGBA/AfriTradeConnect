const mongoose = require('mongoose');
const Product = require('./index').Product;
const Trend = require('./index').Trend;

mongoose.connect('mongodb://localhost:27017/afritrade', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const seedData = async () => {
  await Product.deleteMany({});
  await Trend.deleteMany({});

  await Product.insertMany([
    { name: 'Organic Coffee Beans', price: 15, category: 'coffee', country: 'Kenya', image: 'https://via.placeholder.com/150' },
    { name: 'Handwoven Basket', price: 25, category: 'crafts', country: 'Ghana', image: 'https://via.placeholder.com/150' },
    { name: 'Shea Butter', price: 10, category: 'cosmetics', country: 'Nigeria', image: 'https://via.placeholder.com/150' },
  ]);

  await Trend.insertMany([
    { name: 'Cocoa', price: 200, country: 'Kenya' },
    { name: 'Coffee', price: 150, country: 'Ghana' },
  ]);

  console.log('Data seeded');
  mongoose.connection.close();
};

seedData();