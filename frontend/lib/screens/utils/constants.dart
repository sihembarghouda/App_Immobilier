// utils/constants.dart
class AppConstants {
  // API Configuration
  // TODO: Replace with your deployed backend URL before publishing to Play Store
  // Example: 'https://your-app.onrender.com/api' or 'https://api.immotunisie.tn/api'
  static const String apiBaseUrl =
      'http://localhost:3000/api'; // Change this to your production URL!

  // Mode offline pour tests sans backend (set to FALSE for production)
  static const bool offlineMode =
      false; // IMPORTANT: Must be false for Play Store!

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String propertiesEndpoint = '/properties';
  static const String favoritesEndpoint = '/favorites';
  static const String messagesEndpoint = '/messages';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Property Types
  static const List<String> propertyTypes = [
    'apartment',
    'house',
    'villa',
    'studio',
  ];

  // Transaction Types
  static const List<String> transactionTypes = [
    'sale',
    'rent',
  ];
}
