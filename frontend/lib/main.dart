import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'login_screen_web.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'logistics_screen.dart';
import 'payments_screen.dart';
import 'welcome_screen_web.dart';
import './widgets/config.dart';

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
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == true) {
            return MediaQuery.of(context).size.width > 600
                ? WelcomeScreenWeb()
                : MainScreen(); // Écran principal avec onglets pour mobile
          }
          return MediaQuery.of(context).size.width > 600
              ? LoginScreenWeb()
              : LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => MediaQuery.of(context).size.width > 600
            ? LoginScreenWeb()
            : LoginScreen(),
        '/welcome': (context) => WelcomeScreenWeb(),
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

  // Liste des écrans pour les onglets
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