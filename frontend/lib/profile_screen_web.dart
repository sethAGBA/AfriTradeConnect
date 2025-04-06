import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './widgets/config.dart';
import 'welcome_screen_web.dart';
import 'dashboard_screen_web.dart';
import 'dashboard_logistics_screen_web.dart';
import 'payments_screen_web.dart';

class AppConstants {
  static const String appName = 'AfriTrade Connect';
  static const String logoutTooltip = 'Déconnexion';
  static const String sessionExpired =
      'Session expirée. Veuillez vous reconnecter.';
  static const String profileTitle = 'Profil';
  static const String companyInfo = 'Informations entreprise';
  static const String companyType = 'Type d\'entreprise';
  static const String creditScore = 'Score de crédit';
  static const String transactions = 'Transactions';
  static const String shipments = 'Expéditions';
  static const String rating = 'Rating';
  static const String myDocuments = 'Mes documents';
  static const String paymentPreferences = 'Préférences de paiement';
  static const String security = 'Sécurité';
  static const String comingSoon = 'Fonctionnalité à venir';
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

class ProfileScreenWeb extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreenWeb> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? userName;
  String? userEmail;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchUserProfile();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName');
      userEmail = prefs.getString('userEmail');
    });
  }

  Future<void> fetchUserProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await Config.loadToken();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception('Utilisateur non authentifié');
      }
      final response = await http.get(
        Uri.parse('${Config.usersUrl}/$userId'),
        headers: Config.authHeaders,
      );
      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          if (userData?['name'] != userName) {
            prefs.setString('userName', userData!['name']);
            userName = userData!['name'];
          }
          if (userData?['email'] != userEmail) {
            prefs.setString('userEmail', userData!['email']);
            userEmail = userData!['email'];
          }
        });
      } else if (response.statusCode == 401) {
        await _handleSessionExpired();
      } else {
        throw Exception(
          'Échec du chargement du profil: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleSessionExpired() async {
    await Config.removeToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppConstants.sessionExpired),
          backgroundColor: AppColors.error,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  Future<void> _logout() async {
    await Config.removeToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildMobileDrawer(context) : null,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(isMobile),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: GoogleFonts.poppins(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: fetchUserProfile,
                      child: Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Column(
                        children: [
                          _buildInfoCard(),
                          SizedBox(height: 16),
                          _buildStatsCard(),
                          SizedBox(height: 16),
                          _buildActionsCard(),
                          SizedBox(height: 24),
                          _buildLogoutButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isMobile) {
    return AppBar(
      elevation: 0,
      title:
          isMobile
              ? Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.connecting_airports,
                      size: 28,
                      color: AppColors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      isMobile
                          ? AppConstants.appName.substring(0, 10) + '...'
                          : AppConstants.appName,

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
                  Icon(
                    Icons.connecting_airports,
                    size: 32,
                    color: AppColors.white,
                  ),
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
      actions:
          isMobile
              ? [
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ]
              : [
                _buildAppBarButton(
                  context,
                  'Explorer',
                  Icons.explore,
                  AppRoutes.welcome,
                ),
                _buildAppBarButton(
                  context,
                  'Tableau de bord',
                  Icons.dashboard,
                  AppRoutes.dashboard,
                ),
                _buildAppBarButton(
                  context,
                  'Logistique',
                  Icons.local_shipping,
                  AppRoutes.dashboardLogistics,
                ),
                _buildAppBarButton(
                  context,
                  'Paiements',
                  Icons.payments,
                  AppRoutes.payments,
                ),
                _buildAppBarButton(
                  context,
                  'Profil',
                  Icons.person,
                  AppRoutes.profile,
                ),
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

  Widget _buildAppBarButton(
    BuildContext context,
    String label,
    IconData icon,
    String route,
  ) {
    return TextButton.icon(
      icon: Icon(icon, color: AppColors.white, size: 20),
      label: Text(
        label,
        style: GoogleFonts.poppins(color: AppColors.white, fontSize: 14),
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
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.white,
                  child: Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
                SizedBox(height: 8),
                Text(
                  userName ?? '',
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          _buildMobileMenuItem(
            context,
            'Explorer',
            Icons.explore,
            AppRoutes.welcome,
          ),
          _buildMobileMenuItem(
            context,
            'Tableau de bord',
            Icons.dashboard,
            AppRoutes.dashboard,
          ),
          _buildMobileMenuItem(
            context,
            'Logistique',
            Icons.local_shipping,
            AppRoutes.dashboardLogistics,
          ),
          _buildMobileMenuItem(
            context,
            'Paiements',
            Icons.payments,
            AppRoutes.payments,
          ),
          _buildMobileMenuItem(
            context,
            'Profil',
            Icons.person,
            AppRoutes.profile,
          ),
          Divider(),
          _buildMobileMenuItem(
            context,
            'Déconnexion',
            Icons.logout,
            '',
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    String route, {
    bool isLogout = false,
  }) {
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

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 60, color: AppColors.primary),
          ),
          SizedBox(height: 20),
          Text(
            userName ?? 'Chargement...',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            userEmail ?? '',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              userData?['companyType'] ?? 'Chargement...',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.companyInfo,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow(
              Icons.business,
              AppConstants.companyType,
              userData?['companyType'] ?? 'Chargement...',
            ),
            Divider(height: 24),
            _buildInfoRow(
              Icons.stars,
              AppConstants.creditScore,
              '${userData?['creditScore'] ?? 'N/A'}/1000',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(AppConstants.transactions, '24', Icons.swap_horiz),
            _buildStatItem(AppConstants.shipments, '12', Icons.local_shipping),
            _buildStatItem(AppConstants.rating, '4.8', Icons.star),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActionsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildActionTile(
            AppConstants.myDocuments,
            Icons.folder,
            () => _showComingSoon(context, AppConstants.myDocuments),
          ),
          Divider(height: 1),
          _buildActionTile(
            AppConstants.paymentPreferences,
            Icons.payment,
            () => _showComingSoon(context, AppConstants.paymentPreferences),
          ),
          Divider(height: 1),
          _buildActionTile(
            AppConstants.security,
            Icons.security,
            () => _showComingSoon(context, AppConstants.security),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: _logout,
      icon: Icon(Icons.logout),
      label: Text('Déconnexion'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppConstants.comingSoon} : $featureName'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
