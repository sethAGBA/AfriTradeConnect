
// Fichier séparé pour les constantes (à créer)
import 'dart:ui';

import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'AfriTrade Connect';
  static const String welcomeMessage = 'Bienvenue';
  static const String discoverMessage = 'Découvrez les meilleures opportunités commerciales en Afrique';
  static const String searchHint = 'Rechercher des produits et services...';
  static const String trendsTitle = 'Tendances du marché';
  static const String filtersTitle = 'Filtres';
  static const String categoryLabel = 'Catégorie';
  static const String countryLabel = 'Pays';
  static const String maxPriceLabel = 'Prix max';
  static const String sellNow = 'Vendre maintenant';
  static const String viewDetails = 'Voir détails';
  static const String logoutTooltip = 'Déconnexion';
  static const String sessionExpired = 'Session expirée. Veuillez vous reconnecter.';
}

class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryDarker = Color(0xFF002171);
  static const Color accent = Color(0xFF00B0FF);
  static const Color success = Color(0xFF4CAF50);
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey700 = Color(0xFF616161);
}

class AppRoutes {
  static const String welcome = '/welcome';
  static const String dashboard = '/dashboard';
  static const String dashboardLogistics = '/dashboard_logistics';
  static const String payments = '/payments_web';
  static const String profile = '/profile_web';
  static const String login = '/login';
}