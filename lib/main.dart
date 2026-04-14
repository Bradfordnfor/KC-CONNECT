// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/routes/app_routes.dart';
import 'package:kc_connect/core/routes/app_pages.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // iOS screenshot prevention (Android handled natively in MainActivity.kt)
  if (Platform.isIOS) {
    await NoScreenshot.instance.screenshotOff();
  }

  // Lock to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Restore normal (non-edge-to-edge) mode so system nav bar takes its own
  // space and app content never slides behind it on any page.
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFFF5F5F5),
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
  ));

  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {}
  await Supabase.initialize(
    url: 'https://tirgdzpssgzhhymehjyb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpcmdkenBzc2d6aGh5bWVoanliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE2MTU4NTksImV4cCI6MjA4NzE5MTg1OX0.HYSk7Ssn4kI7jaGH7jvFxh8Yr40gYQ1tk8cAXTG_uh0',
  );
  Get.put(AuthController(), permanent: true);

  // Handle deep links for email confirmation
  final appLinks = AppLinks();
  final initialLink = await appLinks.getInitialLink();
  if (initialLink != null) {
    Supabase.instance.client.auth.getSessionFromUrl(initialLink);
  }

  // Listen for future deep links
  appLinks.uriLinkStream.listen((Uri? uri) {
    if (uri != null) {
      Supabase.instance.client.auth.getSessionFromUrl(uri);
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KC Connect',

      // Theme Configuration
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.backgroundColor),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
        ),
      ),

      // GetX Routes Configuration
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,

      // Ensure every page respects the system navigation bar insets
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.noScaling,
        ),
        child: child!,
      ),

      // Default Transitions
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      // Unknown Route Handler
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => Scaffold(
          appBar: AppBar(
            title: const Text('Page Not Found'),
            backgroundColor: AppColors.white,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.red),
                const SizedBox(height: 16),
                const Text(
                  '404 - Page Not Found',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('The page you are looking for does not exist.'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
