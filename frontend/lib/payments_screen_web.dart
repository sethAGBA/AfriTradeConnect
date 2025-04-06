import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import './widgets/config.dart';

class AppConstants {
  static const String appName = 'AfriTrade Connect';
  static const String logoutTooltip = 'Déconnexion';
  static const String sessionExpired = 'Session expirée. Veuillez vous reconnecter.';
  static const String paymentsTitle = 'Paiements';
  static const String walletTitle = 'Portefeuille';
  static const String creditScoreTitle = 'Score de crédit';
  static const String fundingOptionsTitle = 'Options de financement';
  static const String requestFinancing = 'Demande de financement';
  static const String applyForLoan = 'Demander un prêt';
  static const String deposit = 'Déposer';
}

class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryDarker = Color(0xFF002171);
  static const Color white = Colors.white;
  static const Color success = Color(0xFF4CAF50);
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

class PaymentsScreenWeb extends StatefulWidget {
  @override
  _PaymentsScreenWebState createState() => _PaymentsScreenWebState();
}

class _PaymentsScreenWebState extends State<PaymentsScreenWeb> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildMobileDrawer(context) : null,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(isMobile),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.paymentsTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarker,
                  ),
                ),
                SizedBox(height: 16),
                _buildWalletCards(context),
                SizedBox(height: 32),
                Text(
                  AppConstants.fundingOptionsTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarker,
                  ),
                ),
                SizedBox(height: 16),
                _buildFundingOptions(context),
                SizedBox(height: 32),
              ],
            ),
          ),
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
                    MediaQuery.of(context).size.width < 600
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

  Widget _buildWalletCards(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Column(
        children: [
          _buildWalletCard(),
          SizedBox(height: 16),
          _buildCreditScoreCard(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildWalletCard()),
        SizedBox(width: 16),
        Expanded(child: _buildCreditScoreCard()),
      ],
    );
  }

  Widget _buildWalletCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.walletTitle,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDarker,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '\$3,750',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'GHS 7,500',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            Text(
              'BTC 0.012',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    AppConstants.deposit,
                    style: GoogleFonts.poppins(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditScoreCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.creditScoreTitle,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDarker,
              ),
            ),
            SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(
                    value: 680 / 1000,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                  ),
                ),
                Text(
                  '680',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundingOptions(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Column(
        children: [
          _buildLoanCard(amount: 10000),
          SizedBox(height: 16),
          _buildLoanCard(amount: 20000),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildLoanCard(amount: 10000)),
        SizedBox(width: 16),
        Expanded(child: _buildLoanCard(amount: 20000)),
      ],
    );
  }

  Widget _buildLoanCard({required int amount}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.requestFinancing,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDarker,
              ),
            ),
            Text(
              '\$${amount.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontSize: 24,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                AppConstants.applyForLoan,
                style: GoogleFonts.poppins(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}