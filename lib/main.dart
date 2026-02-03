// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/routes/app_routes.dart';
import 'package:kc_connect/core/routes/app_pages.dart';
import 'package:kc_connect/core/navigation/main_navigation.dart';

void main() {
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
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,

      // Default Transitions
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      // Home page - Uses MainNavigation wrapper for bottom nav
      home: MainNavigation(),

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
