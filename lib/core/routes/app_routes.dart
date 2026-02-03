// lib/core/routes/app_routes.dart

/// Application route constants
/// All routes used in the app are defined here for consistency and type safety
class AppRoutes {
  // Prevent instantiation
  AppRoutes._();

  // ==================== MAIN NAVIGATION ====================
  /// Home page - Main dashboard
  static const String home = '/';

  /// Resources page - Educational materials (O/L, A/L, Other Books)
  static const String resources = '/resources';

  /// Learn page - Chat and AI learning
  static const String learn = '/learn';

  /// Events page - Workshops, seminars, competitions
  static const String events = '/events';

  /// Store page - KC merchandise and products
  static const String store = '/store';

  // ==================== SECONDARY PAGES ====================
  /// AI Chat page - Interactive AI assistant
  static const String aiChat = '/ai-chat';

  /// Alumni page - Alumni directory and mentorship
  static const String alumni = '/alumni';

  /// Alumni detail page - Individual alumni profile
  static const String alumniDetail = '/alumni/detail';

  /// Event detail page - Individual event information
  static const String eventDetail = '/event/detail';

  /// Product detail page - Individual product view
  static const String productDetail = '/product/detail';

  /// Profile page - User profile view
  static const String profile = '/profile';

  /// Edit profile page - Update user information
  static const String editProfile = '/profile/edit';

  /// News/Notifications page - App notifications and news
  static const String news = '/news';

  /// Settings page - App settings and preferences
  static const String settings = '/settings';

  /// Help & Support page - FAQ and support
  static const String help = '/help';

  // ==================== AUTH ROUTES (Future) ====================
  /// Login page
  static const String login = '/login';

  /// Register page
  static const String register = '/register';

  /// Forgot password page
  static const String forgotPassword = '/forgot-password';

  // ==================== HELPER METHODS ====================
  /// Get alumni detail route with ID
  static String getAlumniDetailRoute(String id) => '$alumniDetail?id=$id';

  /// Get event detail route with ID
  static String getEventDetailRoute(String id) => '$eventDetail?id=$id';

  /// Get product detail route with ID
  static String getProductDetailRoute(String id) => '$productDetail?id=$id';
}
