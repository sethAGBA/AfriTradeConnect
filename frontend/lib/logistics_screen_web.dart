import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './widgets/config.dart';

class LogisticsScreenWeb extends StatefulWidget {
  @override
  _LogisticsScreenWebState createState() => _LogisticsScreenWebState();
}

class _LogisticsScreenWebState extends State<LogisticsScreenWeb> {
  // Palette de couleurs cohérente avec les autres écrans
  final Color primaryColor = Color(0xFF1E88E5);
  final Color accentColor = Color(0xFF64B5F6);
  final Color textColor = Color(0xFF2C3E50);
  final Color backgroundColor = Color(0xFFF5F9FF);
  final Color successColor = Color(0xFF4CAF50);
  final Color errorColor = Color(0xFFE57373);

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
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la déconnexion: $e'),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.connecting_airports, size: 32, color: Colors.white),
          SizedBox(width: 12),
          Text(
            'AfriTrade Connect',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: primaryColor,
      actions: [
        _buildNavButton('Explorer', Icons.explore, '/welcome'),
        _buildNavButton('Tableau de bord', Icons.dashboard, '/dashboard'),
        _buildNavButton('Logistique', Icons.local_shipping, '/logistics'),
        _buildNavButton('Paiements', Icons.payments, '/payments'),
        _buildNavButton('Profil', Icons.person, '/profile'),
        IconButton(
          icon: Icon(Icons.logout, color: Colors.white),
          onPressed: _logout,
          tooltip: 'Déconnexion',
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildNavButton(String label, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton.icon(
        onPressed: () {
          print('Navigation vers $route');
          Navigator.pushNamed(context, route);
        },
        icon: Icon(icon, color: Colors.white70, size: 20),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildShipmentHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor, accentColor],
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
              'Suivez votre expédition en temps réel',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
            'Recevez des mises à jour instantanées sur votre envoi',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
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
                Icon(Icons.location_on, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  'Lagos, Nigeria → Accra, Ghana',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShipmentInfo('Expédié', 'Aujourd\'hui, 11:30', Icons.access_time),
                _buildShipmentInfo('Livraison', 'En attente', Icons.local_shipping),
              ],
            ),
            Divider(height: 24),
            Row(
              children: [
                Icon(Icons.inventory_2, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Textiles, 4 articles',
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
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return Container(
      height: 400, // Hauteur fixe pour la carte sur le web
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
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: errorColor),
                        SizedBox(height: 8),
                        Text(
                          'Erreur lors du chargement de la carte',
                          style: GoogleFonts.poppins(color: errorColor),
                        ),
                        SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          style: GoogleFonts.poppins(color: errorColor),
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
            icon: Icon(Icons.flag, color: successColor, size: 48),
          ),
        );
        await controller.drawRoad(
          GeoPoint(latitude: 6.5244, longitude: 3.3792),
          GeoPoint(latitude: 5.6037, longitude: -0.1870),
          roadType: RoadType.car,
          roadOption: RoadOption(
            roadColor: primaryColor,
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
              Icon(Icons.connect_without_contact, color: primaryColor, size: 32),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consolidation de fret',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Regroupez vos envois pour réduire les coûts',
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