import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen_web.dart';
import 'dashboard_logistics_screen_web.dart';
import 'payments_screen_web.dart';
import './widgets/config.dart';

class WelcomeScreenWeb extends StatefulWidget {
  @override
  _WelcomeScreenWebState createState() => _WelcomeScreenWebState();
}

class _WelcomeScreenWebState extends State<WelcomeScreenWeb> {
  String? userName;
  String selectedCategory = 'All';
  String selectedCountry = 'All';
  double priceRange = 1000;
  List products = [];
  List trends = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchProducts();
    fetchTrends();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName');
    });
  }

  Future<void> fetchProducts() async {
    await Config.loadToken();
    final response = await http.get(
      Uri.parse(Config.productsUrl),
      headers: Config.authHeaders,
    );
    if (response.statusCode == 200) {
      setState(() {
        products = jsonDecode(response.body);
      });
    } else {
      await Config.removeToken();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> fetchTrends() async {
    await Config.loadToken();
    final response = await http.get(
      Uri.parse(Config.trendsUrl),
      headers: Config.authHeaders,
    );
    if (response.statusCode == 200) {
      setState(() {
        trends = jsonDecode(response.body);
      });
    }
  }

  Future<void> _logout() async {
    await Config.removeToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    Navigator.pushReplacementNamed(context, '/login');
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.connecting_airports, size: 32),
          SizedBox(width: 12),
          Text('AfriTrade Connect', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      backgroundColor: Colors.blue.shade700,
      actions: [
        _buildNavButton('Explorer', Icons.explore),
        _buildNavButton('Tableau de bord', Icons.dashboard),
        _buildNavButton('Logistique', Icons.local_shipping),
        _buildNavButton('Paiements', Icons.payments),
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: _logout,
          tooltip: 'Déconnexion',
        ),
        SizedBox(width: 16),
      ],
    ),
    body: Container(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 24),
            _buildSearchBar(),
            SizedBox(height: 24),
            _buildFilters(),
            SizedBox(height: 32),
            _buildTrendsSection(),
            SizedBox(height: 32),
            _buildProductsGrid(),
          ],
        ),
      ),
    ),
  );
}

Widget _buildNavButton(String label, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: TextButton.icon(
      onPressed: () {
        // Navigation existante
      },
      icon: Icon(icon, color: Colors.white70, size: 20),
      label: Text(label, style: TextStyle(color: Colors.white, fontSize: 14)),
    ),
  );
}

Widget _buildHeader() {
  return Container(
    padding: EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade600, Colors.blue.shade800],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName != null ? 'Bienvenue, $userName!' : 'Bienvenue!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Découvrez les meilleures opportunités commerciales en Afrique',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.white24,
          child: Icon(Icons.person, size: 32, color: Colors.white),
        ),
      ],
    ),
  );
}

Widget _buildSearchBar() {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher des produits et services...',
              prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.search),
          label: Text('Rechercher'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildFilters() {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            _buildFilterDropdown('Catégorie', selectedCategory),
            SizedBox(width: 16),
            _buildFilterDropdown('Pays', selectedCountry),
            SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prix maximum: ${priceRange.toStringAsFixed(0)} \$',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Slider(
                    value: priceRange,
                    min: 0,
                    max: 1000,
                    onChanged: (value) {
                      setState(() {
                        priceRange = value;
                      });
                    },
                    activeColor: Colors.blue.shade700,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildFilterDropdown(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: Colors.grey[700])),
      SizedBox(height: 8),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<String>(
          value: value,
          underline: SizedBox(),
          items: ['All', 'Coffee', 'Shea Butter', 'Textiles']
              .map((String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              if (label == 'Catégorie') {
                selectedCategory = value!;
              } else {
                selectedCountry = value!;
              }
            });
          },
        ),
      ),
    ],
  );
}

Widget _buildTrendsSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Tendances du marché',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade900,
        ),
      ),
      SizedBox(height: 16),
      Container(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: trends.length,
          itemBuilder: (context, index) {
            return Container(
              width: 200,
              margin: EdgeInsets.only(right: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trends[index]['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${trends[index]['price']} KES/kg',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Vendre maintenant'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          minimumSize: Size(double.infinity, 36),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildProductsGrid() {
  return Expanded(
    child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  products[index]['image'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      products[index]['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '\$${products[index]['price']}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Voir détails'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        minimumSize: Size(double.infinity, 36),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}}