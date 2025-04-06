import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Config {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String? _jwtToken;
  static String? get jwtToken => _jwtToken;
  static set jwtToken(String? value) => _jwtToken = value;
  
static Future<bool> isOffline() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(Duration(seconds: 5));
      return result.isEmpty || result[0].rawAddress.isEmpty;
    } catch (_) {
      return true;
    }
  }

  static Future<void> init() async {
    try {
      await loadToken();
      
      // Vérifier la connexion internet
      final isNetworkAvailable = !(await isOffline());
      
      if (!isNetworkAvailable) {
        throw Exception('Pas de connexion Internet');
      }

      // Vérifier la validité du token
      if (_jwtToken != null) {
        final response = await http.get(
          Uri.parse('$baseUrl/verify-token'),
          headers: authHeaders,
        ).timeout(timeoutDuration);

        if (response.statusCode != 200) {
          await removeToken();
          throw Exception('Session expirée');
        }
      }
    } catch (e) {
      debugPrint('Erreur d\'initialisation: $e');
      // Réinitialiser le token en cas d'erreur
      await removeToken();
      rethrow;
    }
  }

  // ...
  static String get baseUrl {
    if (isProduction) {
      return 'https://afritrade-connect-api.onrender.com';
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:3000'; // Développement sur le web
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000'; // Android Emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:3000'; // iOS Simulator
    } else {
      return 'http://127.0.0.1:3000'; // Développement sur Desktop
    }
  }

  static const Duration timeoutDuration = Duration(seconds: 30);

  static Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_jwtToken != null) 'Authorization': '$_jwtToken',
      };

  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static String get authUrl => '$baseUrl/auth';
  static String get usersUrl => '$baseUrl/user';
  static String get productsUrl => '$baseUrl/products';
  static String get trendsUrl => '$baseUrl/trends';
  static String get shipmentsUrl => '$baseUrl/shipments';
  static String get walletUrl => '$baseUrl/wallet';

  static Future<void> saveToken(String token) async {
    _jwtToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _jwtToken = prefs.getString('jwt_token');
  }

  static Future<void> removeToken() async {
    _jwtToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}