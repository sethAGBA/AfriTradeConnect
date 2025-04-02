const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Connexion à MongoDB
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => console.log('MongoDB connected'))
  .catch(err => console.log(err));

// Modèle Utilisateur
const UserSchema = new mongoose.Schema({
  name: String,
  email: { type: String, unique: true },
  password: String,
  country: String,
  businessType: String,
});
const User = mongoose.model('User', UserSchema);

// Modèle Produit (déjà existant)
const ProductSchema = new mongoose.Schema({
  name: String,
  price: Number,
  category: String,
  country: String,
  image: String,
});
const Product = mongoose.model('Product', ProductSchema);

// Modèle Tendance (déjà existant)
const TrendSchema = new mongoose.Schema({
  name: String,
  price: Number,
  country: String,
});
const Trend = mongoose.model('Trend', TrendSchema);

// API pour l’inscription (Signup)
app.post('/signup', async (req, res) => {
  const { name, email, password, country, businessType } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({ name, email, password: hashedPassword, country, businessType });
    await user.save();
    res.status(201).json({ message: 'User created' });
  } catch (error) {
    res.status(400).json({ error: 'Email already exists' });
  }
});

// API pour la connexion (Login)
app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const user = await User.findOne({ email });
  if (!user) return res.status(400).json({ error: 'User not found' });

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) return res.status(400).json({ error: 'Invalid credentials' });

  const token = jwt.sign({ userId: user._id }, 'secret_key', { expiresIn: '1h' });
  res.json({ token, user: { name: user.name, email: user.email } });
});

// Middleware pour protéger les routes
const authenticateToken = (req, res, next) => {
  const token = req.headers['authorization'];
  if (!token) return res.status(401).json({ error: 'Access denied' });

  try {
    const decoded = jwt.verify(token, 'secret_key');
    req.userId = decoded.userId;
    next();
  } catch (error) {
    res.status(403).json({ error: 'Invalid token' });
  }
};

// API pour les produits (protégée)
app.get('/products', authenticateToken, async (req, res) => {
  const products = await Product.find();
  res.json(products);
});

// API pour les tendances (protégée)
app.get('/trends', authenticateToken, async (req, res) => {
  const trends = await Trend.find();
  res.json(trends);
});

// Lancer le serveur
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));