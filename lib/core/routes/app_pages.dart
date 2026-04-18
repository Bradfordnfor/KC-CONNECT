// lib/core/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:kc_connect/core/navigation/main_navigation.dart';
import 'package:kc_connect/features/admin/presentation/screens/admin_navigation_screen.dart';
import 'package:kc_connect/core/routes/app_routes.dart';
import 'package:kc_connect/features/auth/presentation/screens/check_email_screen.dart';
import 'package:kc_connect/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:kc_connect/features/auth/presentation/screens/login_screen.dart';
import 'package:kc_connect/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:kc_connect/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:kc_connect/features/auth/presentation/screens/splash_screen.dart';
import 'package:kc_connect/features/home/presentation/screens/home_page.dart';
import 'package:kc_connect/features/resources/presentation/screens/resources_page.dart';
import 'package:kc_connect/features/chat/presentation/screens/learn_page.dart';
import 'package:kc_connect/features/chat/presentation/screens/ai_chat_page.dart';
import 'package:kc_connect/features/events/presentation/screens/events_page.dart';
import 'package:kc_connect/features/kstore/presentation/screens/kstore_page.dart';
import 'package:kc_connect/features/alumni/presentation/screens/alumni_page.dart';
import 'package:kc_connect/features/alumni/presentation/screens/alumni_details_page.dart';
import 'package:kc_connect/features/alumni/presentation/screens/mentees_page.dart';
import 'package:kc_connect/features/profile/presentation/screens/profile_page.dart';
import 'package:kc_connect/features/notifications/presentation/screens/news_page.dart';
import 'package:kc_connect/features/help/presentation/screens/help_page.dart';
import 'package:kc_connect/features/settings/presentation/screens/settings_page.dart';

/// GetX Pages Configuration
/// Defines all routes with their corresponding pages and transitions
class AppPages {
  // Prevent instantiation
  AppPages._();

  /// List of all application pages with GetX configuration
  static final pages = [
    // ==================== MAIN NAVIGATION PAGES ====================
    GetPage(
      name: AppRoutes.main, // e.g '/main'
      page: () => MainNavigation(),
    ),

    GetPage(
      name: AppRoutes.admin,
      page: () => AdminMainPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.resources,
      page: () => const ResourcesPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.learn,
      page: () => const LearnPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.events,
      page: () => EventsPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.store,
      page: () => KstorePage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ==================== SECONDARY PAGES ====================
    GetPage(
      name: AppRoutes.aiChat,
      page: () => const AIChatPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.alumni,
      page: () => const AlumniPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.mentees,
      page: () => const MenteesPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.alumniDetail,
      page: () {
        // Get the alumni data from arguments
        final alumniData = Get.arguments as Map<String, dynamic>?;
        return AlumniDetailPage(alumniData: alumniData ?? {});
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.news,
      page: () => const NewsPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ==================== FUTURE PAGES (Placeholders) ====================
    // Uncomment and implement when pages are created

    // GetPage(
    //   name: AppRoutes.eventDetail,
    //   page: () {
    //     final eventData = Get.arguments as Map<String, dynamic>?;
    //     return EventDetailPage(eventData: eventData ?? {});
    //   },
    //   transition: Transition.rightToLeft,
    //   transitionDuration: const Duration(milliseconds: 300),
    // ),

    // GetPage(
    //   name: AppRoutes.productDetail,
    //   page: () {
    //     final productData = Get.arguments as Map<String, dynamic>?;
    //     return ProductDetailPage(productData: productData ?? {});
    //   },
    //   transition: Transition.rightToLeft,
    //   transitionDuration: const Duration(milliseconds: 300),
    // ),

    // GetPage(
    //   name: AppRoutes.editProfile,
    //   page: () => const EditProfilePage(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: const Duration(milliseconds: 300),
    // ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.help,
      page: () => const HelpPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ==================== AUTH PAGES (Future) ====================
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.register,
      page: () => const SignupScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.oTPVerification,
      page: () => const OTPVerificationScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.checkEmail,
      page: () => const CheckEmailScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
