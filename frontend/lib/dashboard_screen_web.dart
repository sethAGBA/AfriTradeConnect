import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './widgets/config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  static const String appName = 'AfriTrade Connect';
  static const String logoutTooltip = 'Déconnexion';
  static const String sessionExpired = 'Session expirée. Veuillez vous reconnecter.';
  static const String dashboardTitle = 'Tableau de bord';
  static const String sales = 'Ventes';
  static const String purchases = 'Achats';
  static const String spending = 'Dépenses';
  static const String creditScore = 'Score de crédit';
  static const String salesPurchases = 'Ventes & Achats';
  static const String creditHistory = 'Historique de crédit';
  static const String recentActivity = 'Activité récente';
  static const String cashFlowHelp = 'Support du flux de trésorerie par segment';
  static const String activeLegs = 'Activité sur les jambes';
  static const String paymentNeeded = 'Paiement nécessaire';
  static const String minutesAgo = 'il y a 25 minutes';
}

class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryDarker = Color(0xFF002171);
  static const Color white = Colors.white;
  static const Color success = Color(0xFF4CAF50);
}

class AppRoutes {
  static const String welcome = '/welcome';
  static const String dashboard = '/dashboard';
  static const String dashboardLogistics = '/dashboard_logistics';
  static const String payments = '/payments_web';
  static const String profile = '/profile_web';
  static const String login = '/login';
}

class DashboardScreenWeb extends StatefulWidget {
  @override
  _DashboardScreenWebState createState() => _DashboardScreenWebState();
}

class _DashboardScreenWebState extends State<DashboardScreenWeb> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildMobileDrawer(context) : null,
      appBar: AppBar(
        elevation: 0,
        title: isMobile
            ? Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.connecting_airports,
                      size: isMobile ? 24 : 32,
                      color: AppColors.white,
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: isMobile ? 18 : 24,
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
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.dashboardTitle,
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildStatsRow(context),
                  SizedBox(height: isMobile ? 16 : 32),
                  Text(
                    AppConstants.salesPurchases,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: isMobile ? 150 : 200,
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
                    child: _buildMainChart(),
                  ),
                  SizedBox(height: isMobile ? 16 : 32),
                  _buildBottomRow(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Column(
        children: [
          _buildStatCard(AppConstants.sales, '\$12,600'),
          SizedBox(height: 12),
          _buildStatCard(AppConstants.purchases, '\$6,200'),
          SizedBox(height: 12),
          _buildStatCard(AppConstants.spending, '\$1,000'),
          SizedBox(height: 12),
          _buildCreditScoreCard(),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(AppConstants.sales, '\$12,600'),
          SizedBox(width: 16),
          _buildStatCard(AppConstants.purchases, '\$6,200'),
          SizedBox(width: 16),
          _buildStatCard(AppConstants.spending, '\$1,000'),
          SizedBox(width: 16),
          _buildCreditScoreCard(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditScoreCard() {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(AppConstants.creditScore, style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  value: 630 / 1000,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '630',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = ['Janv', 'Fév', 'Mars'];
                return value.toInt() < months.length
                    ? Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(months[value.toInt()]),
                      )
                    : Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 5000),
              FlSpot(1, 6000),
              FlSpot(2, 4000),
            ],
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
          ),
          LineChartBarData(
            spots: [
              FlSpot(0, 2000),
              FlSpot(1, 3000),
              FlSpot(2, 2500),
            ],
            isCurved: true,
            color: AppColors.success,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: AppColors.success.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Column(
        children: [
          _buildCreditHistoryCard(),
          SizedBox(height: 16),
          _buildRecentActivityCard(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildCreditHistoryCard()),
        SizedBox(width: 16),
        Expanded(child: _buildRecentActivityCard()),
      ],
    );
  }

  Widget _buildCreditHistoryCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.creditHistory,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              AppConstants.cashFlowHelp,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 100,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final months = ['Janv', 'Fév', 'Mars'];
                          return value.toInt() < months.length ? Text(months[value.toInt()]) : Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 600),
                        FlSpot(1, 650),
                        FlSpot(2, 630),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.recentActivity,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              AppConstants.activeLegs,
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              AppConstants.paymentNeeded,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              AppConstants.minutesAgo,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarButton(BuildContext context, String label, IconData icon, String route) {
    return TextButton.icon(
      icon: Icon(icon, color: AppColors.white),
      label: Text(
        label,
        style: TextStyle(color: AppColors.white),
      ),
      onPressed: () => Navigator.pushNamed(context, route),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
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

  Future<void> _logout() async {
    await Config.removeToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }
}