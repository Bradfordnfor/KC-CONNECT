// lib/core/config/app_constants.dart

class AppConstants {
  // App Info
  static const String appName = 'KC Connect';
  static const String appVersion = '1.0.0';

  // API Endpoints (add your backend URLs here)
  static const String baseUrl = 'https://api.kcconnect.com';
  static const String apiVersion = '/api/v1';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Image Assets
  static const String appIcon = 'assets/images/kc-connect_icon.png';
  static const String defaultAvatar = 'assets/images/default_avatar.png';

  // Resource Categories
  static const List<String> resourceCategories = [
    'Ordinary Level',
    'Advanced Level',
    'Other Books',
  ];

  // Event Types
  static const List<String> eventTypes = [
    'Workshop',
    'Seminar',
    'Competition',
    'Networking',
    'Social',
  ];

  // Store Categories
  static const List<String> storeCategories = [
    'T-Shirts',
    'Hoodies',
    'Accessories',
    'Stationery',
  ];

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
