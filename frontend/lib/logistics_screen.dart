import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:frontend/payments_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/home_screen.dart';
import 'package:frontend/profile_screen.dart';

class LogisticsScreen extends StatefulWidget {
  @override
  _LogisticsScreenState createState() => _LogisticsScreenState();
}

class _LogisticsScreenState extends State<LogisticsScreen> {
  // Couleurs personnalisées
  final Color primaryColor = Color(0xFF1E88E5);
  final Color accentColor = Color(0xFF64B5F6);
  final Color textColor = Color(0xFF2C3E50);
  final Color backgroundColor = Color(0xFFF5F9FF);

  late MapController controller;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildShipmentHeader(),
          _buildShipmentCard(),
          _buildMap(),
          _buildFreightCard(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Suivi logistique',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: primaryColor,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(CupertinoIcons.search, color: Colors.white),
          onPressed: () {},
        ),
      ],
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
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 14,
          fontStyle: FontStyle.normal,
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
                  style: TextStyle(
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
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return Expanded(
      child: Container(
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
          child: OSMFlutter(
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
      ),
    );
  }

  Future<void> _onMapReady(bool isReady) async {
    if (isReady) {
      await controller.addMarker(
        GeoPoint(latitude: 6.5244, longitude: 3.3792),
        markerIcon: MarkerIcon(
          icon: Icon(Icons.location_on, color: Colors.red, size: 48),
        ),
      );
      await controller.addMarker(
        GeoPoint(latitude: 5.6037, longitude: -0.1870),
        markerIcon: MarkerIcon(
          icon: Icon(Icons.flag, color: Colors.green, size: 48),
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
                      style: TextStyle(
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

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey[600],
      currentIndex: 1,
      elevation: 8,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Logistique'),
        BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Paiements'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
        else if (index == 2) {
          // Navigate to Add screen
          // Replace with your Add screen widget
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PaymentsScreen()), // Replace with your Add screen
          );
        }
         else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          );
        }
      },
    );
  }
}