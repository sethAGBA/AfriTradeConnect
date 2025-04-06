import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './widgets/config.dart';
import 'welcome_screen_web.dart';
import 'dashboard_screen_web.dart';
import 'payments_screen_web.dart';
import 'profile_screen.dart';

class AppConstants {
  static const String appName = 'AfriTrade Connect';
  static const String logoutTooltip = 'Déconnexion';
  static const String sessionExpired = 'Session expirée. Veuillez vous reconnecter.';
  static const String shipmentTitle = 'Suivez votre expédition en temps réel';
  static const String shipmentSubtitle = 'Recevez des mises à jour instantanées sur votre envoi';
  static const String routeInfo = 'Lagos, Nigeria → Accra, Ghana';
  static const String shippedLabel = 'Expédié';
  static const String deliveryLabel = 'Livraison';
  static const String shippedTime = 'Aujourd\'hui, 11:30';
  static const String deliveryStatus = 'En attente';
  static const String cargoInfo = 'Textiles, 4 articles';
  static const String freightTitle = 'Consolidation de fret';
  static const String freightSubtitle = 'Regroupez vos envois pour réduire les coûts';
  static const String mapError = 'Erreur lors du chargement de la carte';
}

class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryDarker = Color(0xFF002171);
  static const Color accent = Color(0xFF64B5F6);
  static const Color white = Colors.white;
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE57373);
  static const Color text = Color(0xFF2C3E50);
  static const Color background = Color(0xFFF5F9FF);
}

class AppRoutes {
  static const String welcome = '/welcome';
  static const String dashboard = '/dashboard';
  static const String dashboardLogistics = '/dashboard_logistics';
  static const String payments = '/payments_web';
  static const String profile = '/profile_web';
  static const String login = '/login';
}

class DashboardLogisticsScreenWeb extends StatefulWidget {
  @override
  _LogisticsScreenWebState createState() => _LogisticsScreenWebState();
}

class _LogisticsScreenWebState extends State<DashboardLogisticsScreenWeb> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late MapController controller;
  bool isMapLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    controller = MapController(
      initPosition: GeoPoint(latitude: 6.5244, longitude: 3.3792),
      areaLimit: BoundingBox(
        east: 30.0,
        north: 15.0,
        south: -15.0,
        west: -20.0,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    try {
      await Config.removeToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('userName');
      await prefs.remove('userEmail');
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppConstants.sessionExpired}: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildMobileDrawer(context) : null,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(isMobile),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildShipmentHeader(),
            _buildShipmentCard(),
            _buildMap(),
            _buildFreightCard(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isMobile) {
    return AppBar(
      elevation: 0,
      title: isMobile
          ? Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.connecting_airports, size: 28, color: AppColors.white),
                  SizedBox(width: 8),
                  Text(
                    isMobile ? AppConstants.appName.substring(0, 10) + '...' : AppConstants.appName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                Icon(Icons.connecting_airports, size: 32, color: AppColors.white),
                SizedBox(width: 12),
                Text(
                  AppConstants.appName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
      backgroundColor: AppColors.primaryDark,
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
    );
  }

  Widget _buildAppBarButton(BuildContext context, String label, IconData icon, String route) {
    return TextButton.icon(
      icon: Icon(icon, color: AppColors.white, size: 20),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: AppColors.white,
          fontSize: 14,
        ),
      ),
      onPressed: () => Navigator.pushNamed(context, route),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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

  Widget _buildShipmentHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              AppConstants.shipmentTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            AppConstants.shipmentSubtitle,
            style: GoogleFonts.poppins(
              color: AppColors.white.withOpacity(0.8),
              fontSize: 14,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(1, 1),
                  blurRadius: 1,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentCard() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  AppConstants.routeInfo,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShipmentInfo(AppConstants.shippedLabel, AppConstants.shippedTime, Icons.access_time),
                _buildShipmentInfo(AppConstants.deliveryLabel, AppConstants.deliveryStatus, Icons.local_shipping),
              ],
            ),
            Divider(height: 24),
            Row(
              children: [
                Icon(Icons.inventory_2, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  AppConstants.cargoInfo,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShipmentInfo(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return Container(
      height: 400,
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isMapLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        SizedBox(height: 8),
                        Text(
                          AppConstants.mapError,
                          style: GoogleFonts.poppins(color: AppColors.error),
                        ),
                        SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          style: GoogleFonts.poppins(color: AppColors.error),
                        ),
                      ],
                    ),
                  )
                : OSMFlutter(
                    controller: controller,
                    osmOption: const OSMOption(
                      zoomOption: ZoomOption(
                        initZoom: 5,
                        minZoomLevel: 2,
                        maxZoomLevel: 18,
                        stepZoom: 1.0,
                      ),
                    ),
                    onMapIsReady: _onMapReady,
                  ),
      ),
    );
  }

  Future<void> _onMapReady(bool isReady) async {
    if (isReady) {
      try {
        setState(() => isMapLoading = false);
        await controller.addMarker(
          GeoPoint(latitude: 6.5244, longitude: 3.3792),
          markerIcon: MarkerIcon(
            icon: Icon(Icons.location_on, color: Colors.red, size: 48),
          ),
        );
        await controller.addMarker(
          GeoPoint(latitude: 5.6037, longitude: -0.1870),
          markerIcon: MarkerIcon(
            icon: Icon(Icons.flag, color: AppColors.success, size: 48),
          ),
        );
        await controller.drawRoad(
          GeoPoint(latitude: 6.5244, longitude: 3.3792),
          GeoPoint(latitude: 5.6037, longitude: -0.1870),
          roadType: RoadType.car,
          roadOption: RoadOption(
            roadColor: AppColors.primary,
            roadWidth: 10,
          ),
        );
      } catch (e) {
        setState(() {
          isMapLoading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  Widget _buildFreightCard() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.connect_without_contact, color: AppColors.primary, size: 32),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.freightTitle,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      AppConstants.freightSubtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}