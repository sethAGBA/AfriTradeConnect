import 'package:flutter/material.dart';
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
                      : HomeScreen();
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
        '/payments': (context) => PaymentsScreen(),
        '/orders': (context) => OrdersScreen(),
        '/welcome': (context) => WelcomeScreenWeb(),
        '/dashboard': (context) => DashboardScreenWeb(),
        '/dashboard_logistics': (context) => DashboardLogisticsScreenWeb(),
        '/payments_web': (context) => PaymentsScreenWeb(),
      },
    );
  }
}