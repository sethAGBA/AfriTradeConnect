import 'package:flutter/material.dart';
import 'package:frontend/profile_screen_web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'login_screen_web.dart';
import 'home_screen.dart';
import './widgets/config.dart';
import 'signup_screen.dart';
import 'signup_screen_web.dart';
import 'profile_screen.dart';
import 'logistics_screen.dart';
import 'payments_screen.dart';
import 'orders_screen.dart';
import 'welcome_screen_web.dart';
import 'dashboard_screen_web.dart';
import 'dashboard_logistics_screen_web.dart';
import 'payments_screen_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Config.loadToken(); // Chargez le token au démarrage
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token') != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AfriTrade Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
              future: _checkLoginStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data == true) {
                  return MediaQuery.of(context).size.width > 600
                      ? WelcomeScreenWeb()
                      : MainScreen();
                }
                return MediaQuery.of(context).size.width > 600
                    ? LoginScreenWeb()
                    : LoginScreen();
              },
            ),
        '/login': (context) => MediaQuery.of(context).size.width > 600
            ? LoginScreenWeb()
            : LoginScreen(),
        '/signup': (context) => MediaQuery.of(context).size.width > 600
            ? SignUpScreenWeb()
            : SignUpScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/logistics': (context) => LogisticsScreen(),
        '/logistics_web': (context) => DashboardLogisticsScreenWeb(),
        '/payments': (context) => PaymentsScreen(),
        '/orders': (context) => OrdersScreen(),
        '/welcome': (context) => WelcomeScreenWeb(),
        '/dashboard': (context) => DashboardScreenWeb(),
        '/dashboard_logistics': (context) => DashboardLogisticsScreenWeb(),
        '/payments_web': (context) => PaymentsScreenWeb(),
        '/profile_web': (context) => ProfileScreenWeb(),
      },
      onUnknownRoute: (settings) {
        // Gestion des routes inconnues pour éviter les crashs
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Route inconnue : ${settings.name}'),
            ),
          ),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    LogisticsScreen(),
    PaymentsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('MainScreen loaded'); // Pour débogage
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        elevation: 8,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Logistique'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Paiements'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}