import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen_web.dart';
import 'dashboard_logistics_screen_web.dart';
import 'payments_screen_web.dart';
import 'profile_screen.dart';
import './widgets/config.dart';

class AppConstants {
  static const String appName = 'AfriTrade Connect';
  static const String welcomeMessage = 'Bienvenue';
  static const String discoverMessage = 'Découvrez les meilleures opportunités commerciales en Afrique';
  static const String searchHint = 'Rechercher des produits et services...';
  static const String trendsTitle = 'Tendances du marché';
  static const String filtersTitle = 'Filtres';
  static const String categoryLabel = 'Catégorie';
  static const String countryLabel = 'Pays';
  static const String maxPriceLabel = 'Prix max';
  static const String sellNow = 'Vendre maintenant';
  static const String viewDetails = 'Voir détails';
  static const String logoutTooltip = 'Déconnexion';
  static const String sessionExpired = 'Session expirée. Veuillez vous reconnecter.';
}

class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryDarker = Color(0xFF002171);
  static const Color accent = Color(0xFF00B0FF);
  static const Color success = Color(0xFF4CAF50);
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey700 = Color(0xFF616161);
}

class AppRoutes {
  static const String welcome = '/welcome';
  static const String dashboard = '/dashboard';
  static const String dashboardLogistics = '/dashboard_logistics';
  static const String payments = '/payments_web';
  static const String profile = '/profile_web';
  static const String login = '/login';
}

class WelcomeScreenWeb extends StatefulWidget {
  @override
  _WelcomeScreenWebState createState() => _WelcomeScreenWebState();
}

class _WelcomeScreenWebState extends State<WelcomeScreenWeb> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String userName = 'Invité';
  String selectedCategory = 'Tous';
  String selectedCountry = 'Tous';
  double priceRange = 1000;
  List products = [];
  List trends = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        loadUserData();
        fetchData();
      }
    });
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Invité';
    });
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      await Future.wait([
        fetchProducts().catchError((e) => print('Products error: $e')),
        fetchTrends().catchError((e) => print('Trends error: $e')),
      ]);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> fetchProducts() async {
    try {
      await Config.loadToken();
      final response = await http.get(
        Uri.parse(Config.productsUrl),
        headers: Config.authHeaders,
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() => products = jsonDecode(response.body));
        }
      } else if (response.statusCode == 401) {
        await _handleSessionExpired();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> fetchTrends() async {
    try {
      await Config.loadToken();
      final response = await http.get(
        Uri.parse(Config.trendsUrl),
        headers: Config.authHeaders,
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200 && mounted) {
        setState(() => trends = jsonDecode(response.body));
      }
    } catch (e) {
      print('Erreur trends: $e');
    }
  }

  Future<void> _handleSessionExpired() async {
    await Config.removeToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppConstants.sessionExpired)),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  List get filteredProducts {
    return products.where((product) {
      final matchesCategory = selectedCategory == 'Tous' || 
                           product['category'] == selectedCategory;
      final matchesCountry = selectedCountry == 'Tous' || 
                          product['country'] == selectedCountry;
      final matchesPrice = product['price'] <= priceRange;
      return matchesCategory && matchesCountry && matchesPrice;
    }).toList();
  }

  Future<void> _logout() async {
    await Config.removeToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildMobileDrawer(context) : null,
      appBar: AppBar(
        elevation: 4,
        backgroundColor: AppColors.primaryDark,
        title: isMobile
            ? Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.connecting_airports,
                      color: AppColors.white,
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Text(
                        isMobile ? AppConstants.appName.substring(0, 10) + '...' : AppConstants.appName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              )
            : Row(
                children: [
                  Icon(
                    Icons.connecting_airports,
                    color: AppColors.white,
                    size: 36,
                  ),
                  SizedBox(width: 16),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
        actions: isMobile
            ? [
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ]
            : [
                _buildAppBarButton(context, 'Explorer', Icons.explore, AppRoutes.welcome),
                _buildAppBarButton(context, 'Tableau de bord', Icons.dashboard, AppRoutes.dashboard),
                _buildAppBarButton(context, 'Logistique', Icons.local_shipping, AppRoutes.dashboardLogistics),
                _buildAppBarButton(context, 'Paiements', Icons.payments, AppRoutes.payments),
                _buildAppBarButton(context, 'Profil', Icons.person, AppRoutes.profile),
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: _logout,
                  tooltip: AppConstants.logoutTooltip,
                ),
                SizedBox(width: 16),
              ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primaryDarker],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  color: Colors.grey[50],
                  child: RefreshIndicator(
                    onRefresh: fetchData,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(_getPadding(constraints.maxWidth)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(constraints),
                          SizedBox(height: 24),
                          _buildSearchBar(constraints),
                          SizedBox(height: 24),
                          _buildFilters(constraints),
                          SizedBox(height: 32),
                          _buildTrendsSection(constraints),
                          SizedBox(height: 32),
                          _buildProductsGrid(constraints),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryDarker],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.connecting_airports, size: 48, color: AppColors.white),
                SizedBox(height: 8),
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Bienvenue, $userName',
                  style: TextStyle(
                    color: AppColors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          _buildMobileMenuItem(context, 'Explorer', Icons.explore, AppRoutes.welcome),
          _buildMobileMenuItem(context, 'Tableau de bord', Icons.dashboard, AppRoutes.dashboard),
          _buildMobileMenuItem(context, 'Logistique', Icons.local_shipping, AppRoutes.dashboardLogistics),
          _buildMobileMenuItem(context, 'Paiements', Icons.payments, AppRoutes.payments),
          _buildMobileMenuItem(context, 'Profil', Icons.person, AppRoutes.profile),
          Divider(),
          _buildMobileMenuItem(context, 'Déconnexion', Icons.logout, '', isLogout: true),
        ],
      ),
    );
  }

  Widget _buildMobileMenuItem(BuildContext context, String title, IconData icon, String route,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (isLogout) {
          _logout();
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  Widget _buildAppBarButton(BuildContext context, String label, IconData icon, String route) {
    return TextButton.icon(
      icon: Icon(icon, color: AppColors.white),
      label: Text(label, style: TextStyle(color: AppColors.white)),
      onPressed: () => Navigator.pushNamed(context, route),
    );
  }

  // ... (le reste des méthodes _buildHeader, _buildSearchBar, etc. reste inchangé)
  // [Les autres méthodes de construction d'UI restent identiques à la version précédente]
  double _getPadding(double width) {
    if (width > 600) return 32.0;
    if (width > 300) return 16.0;
    if (width > 200) return 12.0;
    return 8.0;
  }

  Widget _buildHeader(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final isWideScreen = width > 600;
    final fontSizeTitle = width > 300 ? 28.0 : width > 200 ? 24.0 : 20.0;
    final fontSizeSubtitle = width > 300 ? 16.0 : width > 200 ? 14.0 : 12.0;
    final avatarRadius = width > 300 ? 32.0 : width > 200 ? 24.0 : 20.0;

    return Container(
      padding: EdgeInsets.all(_getPadding(width)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: isWideScreen
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppConstants.welcomeMessage}, $userName!',
                      style: TextStyle(
                        fontSize: fontSizeTitle,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      AppConstants.discoverMessage,
                      style: TextStyle(fontSize: fontSizeSubtitle, color: AppColors.white70),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: avatarRadius, color: AppColors.white),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: avatarRadius, color: AppColors.white),
                ),
                SizedBox(height: 16),
                Text(
                  '${AppConstants.welcomeMessage}, $userName!',
                  style: TextStyle(
                    fontSize: fontSizeTitle,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  AppConstants.discoverMessage,
                  style: TextStyle(fontSize: fontSizeSubtitle, color: AppColors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final isWideScreen = width > 600;
    final buttonPadding = width > 300 
        ? EdgeInsets.symmetric(horizontal: 24, vertical: 12) 
        : EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: isWideScreen
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: AppConstants.searchHint,
                      prefixIcon: Icon(Icons.search, color: AppColors.primary),
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: AppColors.grey300),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.search),
                  label: Text(AppConstants.searchHint.split('...')[0]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: buttonPadding,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: AppConstants.searchHint,
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.grey300),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.search),
                  label: Text(AppConstants.searchHint.split('...')[0]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: buttonPadding,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilters(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final isWideScreen = width > 900;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
            AppConstants.filtersTitle,
            style: TextStyle(
              fontSize: width > 300 ? 18.0 : width > 200 ? 16.0 : 14.0,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDarker,
            ),
          ),
          SizedBox(height: 16),
          isWideScreen
              ? Row(
                  children: [
                    _buildFilterDropdown(AppConstants.categoryLabel, selectedCategory, width),
                    SizedBox(width: 16),
                    _buildFilterDropdown(AppConstants.countryLabel, selectedCountry, width),
                    SizedBox(width: 32),
                    Expanded(child: _buildPriceSlider()),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFilterDropdown(AppConstants.categoryLabel, selectedCategory, width),
                        SizedBox(width: 16),
                        _buildFilterDropdown(AppConstants.countryLabel, selectedCountry, width),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildPriceSlider(),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.grey700, fontSize: width > 200 ? 14.0 : 12.0)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            underline: SizedBox(),
            items: ['Tous', 'Café', 'Beurre de karité', 'Textiles']
                .map((String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: width > 200 ? 14.0 : 12.0)),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                if (label == AppConstants.categoryLabel) {
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

  Widget _buildPriceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppConstants.maxPriceLabel}: ${priceRange.toStringAsFixed(0)} \$',
          style: TextStyle(color: AppColors.grey700),
        ),
        Slider(
          value: priceRange,
          min: 0,
          max: 1000,
          divisions: 10,
          label: priceRange.toStringAsFixed(0),
          onChanged: (value) => setState(() => priceRange = value),
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildTrendsSection(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final itemWidth = width > 600 ? 200.0 : width > 300 ? width * 0.45 : width * 0.8;
    final fontSize = width > 300 ? 16.0 : width > 200 ? 14.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.trendsTitle,
          style: TextStyle(
            fontSize: width > 300 ? 24.0 : width > 200 ? 20.0 : 18.0,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDarker,
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
                width: itemWidth,
                margin: EdgeInsets.only(right: 16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trends[index]['name'],
                          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${trends[index]['price']} KES/kg',
                          style: TextStyle(
                            fontSize: fontSize + 4,
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        ElevatedButton(
                          key: Key('trendButton_$index'),
                          onPressed: () {},
                          child: Text(AppConstants.sellNow, style: TextStyle(fontSize: fontSize - 2)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
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

  Widget _buildProductsGrid(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final crossAxisCount = width > 1200
        ? 4
        : width > 900
            ? 3
            : width > 600
                ? 2
                : 1;
    final fontSize = width > 300 ? 16.0 : width > 200 ? 14.0 : 12.0;
    final imageHeight = width > 300 ? 180.0 : width > 200 ? 150.0 : 120.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: width > 300 ? 0.75 : width > 200 ? 0.8 : 0.9,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: filteredProducts[index],
          imageHeight: imageHeight,
          fontSize: fontSize,
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final double imageHeight;
  final double fontSize;

  const ProductCard({
    Key? key,
    required this.product,
    required this.imageHeight,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              product['image'],
              height: imageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: imageHeight,
                color: Colors.grey[200],
                child: Icon(Icons.error, color: Colors.red),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: imageHeight,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  '\$${product['price']}',
                  style: TextStyle(
                    fontSize: fontSize + 2,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  key: Key('productButton_${product['id']}'),
                  onPressed: () {},
                  child: Text(AppConstants.viewDetails, style: TextStyle(fontSize: fontSize - 2)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: Size(double.infinity, 36),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}