// const express = require('express');
// const mongoose = require('mongoose');
// const bcrypt = require('bcryptjs');
// const jwt = require('jsonwebtoken');
// const cors = require('cors');
// require('dotenv').config();

// // Initialisation de l'application Express
// const app = express();

// // Configuration de CORS pour autoriser les requêtes depuis l'application Flutter
// app.use(cors({
//   origin: [
//     'http://localhost:4200', // Pour le développement web local
//     'http://127.0.0.1:4200', // Pour le développement web local
//     'http://localhost:3000', // Pour les tests locaux
//     'https://your-flutter-web-app-domain.com', // Remplacez par le domaine de votre application web déployée
//   ],
//   methods: ['GET', 'POST', 'PUT', 'DELETE'],
//   allowedHeaders: ['Content-Type', 'Authorization'],
// }));

// // Middleware pour parser les requêtes JSON
// app.use(express.json());

// // Connexion à MongoDB
// mongoose.connect(process.env.MONGODB_URI, {
//   useNewUrlParser: true,
//   useUnifiedTopology: true,
// })
//   .then(() => console.log('Connected to MongoDB'))
//   .catch((err) => console.error('MongoDB connection error:', err));

// // Définition du schéma et du modèle pour les utilisateurs
// const userSchema = new mongoose.Schema({
//   name: { type: String, required: true },
//   email: { type: String, required: true, unique: true },
//   password: { type: String, required: true },
//   companyType: { type: String, enum: ['SME', 'Freight Forwarder', 'Buyer'], required: true },
//   creditScore: { type: Number, default: 500 },
//   wallet: { type: Number, default: 0 },
// });

// const User = mongoose.model('User', userSchema);

// // Définition du schéma et du modèle pour les produits
// const productSchema = new mongoose.Schema({
//   name: { type: String, required: true },
//   price: { type: Number, required: true },
//   image: { type: String, required: true },
//   category: { type: String, required: true },
//   country: { type: String, required: true },
// });

// const Product = mongoose.model('Product', productSchema);

// // Définition du schéma et du modèle pour les tendances
// const trendSchema = new mongoose.Schema({
//   name: { type: String, required: true },
//   price: { type: Number, required: true },
// });

// const Trend = mongoose.model('Trend', trendSchema);

// // Définition du schéma et du modèle pour les expéditions
// const shipmentSchema = new mongoose.Schema({
//   userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
//   productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
//   status: { type: String, enum: ['Pending', 'Shipped', 'Delivered'], default: 'Pending' },
//   createdAt: { type: Date, default: Date.now },
// });

// const Shipment = mongoose.model('Shipment', shipmentSchema);

// // Middleware pour vérifier le token JWT
// const authenticateToken = (req, res, next) => {
//   const authHeader = req.headers['authorization'];
//   const token = authHeader;

//   if (!token) {
//     return res.status(401).json({ error: 'Access denied. No token provided.' });
//   }

//   try {
//     const decoded = jwt.verify(token, process.env.JWT_SECRET);
//     req.user = decoded;
//     next();
//   } catch (err) {
//     res.status(403).json({ error: 'Invalid token.' });
//   }
// };

// // Route pour l'inscription
// app.post('/auth/signup', async (req, res) => {
//   const { name, email, password, companyType } = req.body;

//   try {
//     // Vérifier si l'utilisateur existe déjà
//     const existingUser = await User.findOne({ email });
//     if (existingUser) {
//       return res.status(400).json({ error: 'Email already exists' });
//     }

//     // Hacher le mot de passe
//     const hashedPassword = await bcrypt.hash(password, 10);

//     // Créer un nouvel utilisateur
//     const user = new User({
//       name,
//       email,
//       password: hashedPassword,
//       companyType,
//     });

//     await user.save();

//     // Générer un token JWT
//     const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });

//     // Retourner le token et les informations utilisateur
//     res.status(201).json({
//       token,
//       user: {
//         _id: user._id,
//         name: user.name,
//         email: user.email,
//         companyType: user.companyType,
//       },
//     });
//   } catch (err) {
//     console.error('Signup error:', err);
//     res.status(500).json({ error: 'Server error' });
//   }
// });

// // Route pour la connexion
// app.post('/auth/login', async (req, res) => {
//   const { email, password } = req.body;

//   try {
//     // Vérifier si l'utilisateur existe
//     const user = await User.findOne({ email });
//     if (!user) {
//       return res.status(401).json({ error: 'Invalid credentials' });
//     }

//     // Vérifier le mot de passe
//     const isMatch = await bcrypt.compare(password, user.password);
//     if (!isMatch) {
//       return res.status(401).json({ error: 'Invalid credentials' });
//     }

//     // Générer un token JWT
//     const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });

//     // Retourner le token et les informations utilisateur
//     res.status(200).json({
//       token,
//       user: {
//         _id: user._id,
//         name: user.name,
//         email: user.email,
//         companyType: user.companyType,
//       },
//     });
//   } catch (err) {
//     console.error('Login error:', err);
//     res.status(500).json({ error: 'Server error' });
//   }
// });

// // Route pour récupérer les informations d'un utilisateur
// app.get('/user/:id', authenticateToken, async (req, res) => {
//   try {
//     const user = await User.findById(req.params.id).select('-password');
//     if (!user) {
//       return res.status(404).json({ error: 'User not found' });
//     }

//     // Vérifier que l'utilisateur authentifié a le droit d'accéder à ces données
//     if (req.user.userId !== user._id.toString()) {
//       return res.status(403).json({ error: 'Access denied' });
//     }

//     res.status(200).json(user);
//   } catch (err) {
//     console.error('Get user error:', err);
//     res.status(500).json({ error: 'Server error' });
//   }
// });

// // Route pour récupérer tous les produits
// app.get('/products', authenticateToken, async (req, res) => {
//   try {
//     const products = await Product.find();
//     res.status(200).json(products);
//   } catch (err) {
//     console.error('Get products error:', err);
//     res.status(500).json({ error: 'Server error' });
//   }
// });

// // Route pour ajouter un produit (exemple de données statiques pour les tests)
// app.post('/products', authenticateToken, async (req, res) => {
//   try {
//     const product = new Product(req.body);
//     await product.save();
//     res.status(201).json(product);
//   } catch (err) {
//     console.error('Add product error:', err);
//     res.status(500).json({ error: 'Server error' });
//   }
// });

// // Route pour récupérer les tendances
// app.get('/trends', authenticateToken, async (req, res) => {
//   try {
//     const trends = await Trend.find();
//     res.status(200).json(trends);
//   } catch (err) {
//     console.error('Get trends error:', err);
//     res.status(500).json({ error: 'Server error' });
//   }
// });

// // Route pour ajouter une tendance (exemple de données statiques pour les tests)
// app.post('/trends', authenticateToken, async (req, res) => {
//   try {
//     const trend = new Trend(req.body);
//     await trend.save();
//     res.status(201).json(trend);
//   } catch (err) {
//     console.error('Add trend error:', err);
//     res.status(500).json({ error: 'Server error' });
//   }
// });

// // Route pour créer une expédition
// app.post('/shipments', authenticateToken, async (req, res) => {
//   try {
//     const shipment = new Shipment({
//       userId: req.user.userId,
//       productId: req.body.productId,
//       status: 'Pending',
//     });

//     await shipment.save();
//     res.status(201).json(shipment);
//   } catch (err) {
//     console.error('Create shipment error:', err);
//     res.status(500).json({ error: 'Server error' });
//   }
// });

// // Route pour récupérer les expéditions d'un utilisateur
// app.get('/shipments', authenticateToken, async (req, res) => {
//   try {
//     const shipments = await Shipment.find({ userId: req.user.userId }).populate('productId');
//     res.status(200).json(shipments);
//   } catch (err) {
//     console.error('Get shipments error:', err);
//     res.status(500).json({ error: 'Server error' });
//   }
// });

// // Route pour récupérer le portefeuille d'un utilisateur
// app.get('/wallet', authenticateToken, async (req, res) => {
//   try {
//     const user = await User.findById(req.user.userId).select('wallet');
//     if (!user) {
//       return res.status(404).json({ error: 'User not found' });
//     }
//     res.status(200).json({ wallet: user.wallet });
//   } catch (err) {
//     console.error('Get wallet error:', err);
//     res.status(500).json({ error: 'Server error' });
//   }
// });

// // Route pour mettre à jour le portefeuille d'un utilisateur
// app.put('/wallet', authenticateToken, async (req, res) => {
//   try {
//     const { amount } = req.body;
//     const user = await User.findById(req.user.userId);
//     if (!user) {
//       return res.status(404).json({ error: 'User not found' });
//     }

//     user.wallet += amount;
//     await user.save();

//     res.status(200).json({ wallet: user.wallet });
//   } catch (err) {
//     console.error('Update wallet error:', err);
//     res.status(500).json({ error: 'Server error' });
//   }
// });

// // Route de test pour vérifier que le serveur fonctionne
// app.get('/', (req, res) => {
//   res.json({ message: 'AfriTrade Connect API is running' });
// });

// // Démarrer le serveur
// const PORT = process.env.PORT || 3000;
// app.listen(PORT, () => {
//   console.log(`Server running on port ${PORT}`);
// });




const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
require('dotenv').config();

// Vérifier que JWT_SECRET est défini
if (!process.env.JWT_SECRET) {
  console.error('Erreur : La variable d\'environnement JWT_SECRET n\'est pas définie dans le fichier .env');
  process.exit(1);
}

// Initialisation de l'application Express
const app = express();

// Configuration de CORS pour autoriser toutes les origines (développement uniquement)
app.use(cors());

// Middleware pour parser les requêtes JSON
app.use(express.json());

// Connexion à MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch((err) => console.error('MongoDB connection error:', err));

// Définition du schéma et du modèle pour les utilisateurs
const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  companyType: { type: String, enum: ['SME', 'Freight Forwarder', 'Buyer'], required: true },
  creditScore: { type: Number, default: 500 },
  wallet: { type: Number, default: 0 },
});

const User = mongoose.model('User', userSchema);

// Définition du schéma et du modèle pour les produits
const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  price: { type: Number, required: true },
  image: { type: String, required: true },
  category: { type: String, required: true },
  country: { type: String, required: true },
});

const Product = mongoose.model('Product', productSchema);

// Définition du schéma et du modèle pour les tendances
const trendSchema = new mongoose.Schema({
  name: { type: String, required: true },
  price: { type: Number, required: true },
});

const Trend = mongoose.model('Trend', trendSchema);

// Définition du schéma et du modèle pour les expéditions
const shipmentSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
  status: { type: String, enum: ['Pending', 'Shipped', 'Delivered'], default: 'Pending' },
  createdAt: { type: Date, default: Date.now },
});

const Shipment = mongoose.model('Shipment', shipmentSchema);

// Middleware pour vérifier le token JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader;

  if (!token) {
    return res.status(401).json({ error: 'Access denied. No token provided.' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    res.status(403).json({ error: 'Invalid token.' });
  }
};

// Route pour l'inscription
app.post('/auth/signup', async (req, res) => {
  const { name, email, password, companyType } = req.body;

  try {
    // Vérifier si l'utilisateur existe déjà
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'Email already exists' });
    }

    // Hacher le mot de passe
    const hashedPassword = await bcrypt.hash(password, 10);

    // Créer un nouvel utilisateur
    const user = new User({
      name,
      email,
      password: hashedPassword,
      companyType,
    });

    await user.save();

    // Générer un token JWT
    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });

    // Retourner le token et les informations utilisateur
    res.status(201).json({
      token,
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        companyType: user.companyType,
      },
    });
  } catch (err) {
    console.error('Signup error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Route pour la connexion
app.post('/auth/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    // Vérifier si l'utilisateur existe
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Vérifier le mot de passe
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Générer un token JWT
    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });

    // Retourner le token et les informations utilisateur
    res.status(200).json({
      token,
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        companyType: user.companyType,
      },
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Route pour récupérer les informations d'un utilisateur
app.get('/user/:id', authenticateToken, async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Vérifier que l'utilisateur authentifié a le droit d'accéder à ces données
    if (req.user.userId !== user._id.toString()) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.status(200).json(user);
  } catch (err) {
    console.error('Get user error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Route pour récupérer tous les produits
app.get('/products', authenticateToken, async (req, res) => {
  try {
    const products = await Product.find();
    res.status(200).json(products);
  } catch (err) {
    console.error('Get products error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Route pour ajouter un produit (exemple de données statiques pour les tests)
app.post('/products', authenticateToken, async (req, res) => {
  try {
    const product = new Product(req.body);
    await product.save();
    res.status(201).json(product);
  } catch (err) {
    console.error('Add product error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Route pour récupérer les tendances
app.get('/trends', authenticateToken, async (req, res) => {
  try {
    const trends = await Trend.find();
    res.status(200).json(trends);
  } catch (err) {
    console.error('Get trends error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Route pour ajouter une tendance (exemple de données statiques pour les tests)
app.post('/trends', authenticateToken, async (req, res) => {
  try {
    const trend = new Trend(req.body);
    await trend.save();
    res.status(201).json(trend);
  } catch (err) {
    console.error('Add trend error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Route pour créer une expédition
app.post('/shipments', authenticateToken, async (req, res) => {
  try {
    const shipment = new Shipment({
      userId: req.user.userId,
      productId: req.body.productId,
      status: 'Pending',
    });

    await shipment.save();
    res.status(201).json(shipment);
  } catch (err) {
    console.error('Create shipment error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Route pour récupérer les expéditions d'un utilisateur
app.get('/shipments', authenticateToken, async (req, res) => {
  try {
    const shipments = await Shipment.find({ userId: req.user.userId }).populate('productId');
    res.status(200).json(shipments);
  } catch (err) {
    console.error('Get shipments error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Route pour récupérer le portefeuille d'un utilisateur
app.get('/wallet', authenticateToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.userId).select('wallet');
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.status(200).json({ wallet: user.wallet });
  } catch (err) {
    console.error('Get wallet error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Route pour mettre à jour le portefeuille d'un utilisateur
app.put('/wallet', authenticateToken, async (req, res) => {
  try {
    const { amount } = req.body;
    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    user.wallet += amount;
    await user.save();

    res.status(200).json({ wallet: user.wallet });
  } catch (err) {
    console.error('Update wallet error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Route de test pour vérifier que le serveur fonctionne
app.get('/', (req, res) => {
  res.json({ message: 'AfriTrade Connect API is running' });
});

// Démarrer le serveur
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});