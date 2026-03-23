import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/config/app_constants.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _checkAuthStatus();
    });
  }

  void _checkAuthStatus() {
    // TODO: Check if user is logged in with Supabase
    // final session = Supabase.instance.client.auth.currentSession;
    // if (session != null) {
    //   Get.offAllNamed(AppRoutes.main);
    // } else {
    //   Get.offAllNamed(AppRoutes.login);
    // }

    // For now, navigate to login
    Get.offAllNamed('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.gradientColor),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AppConstants.appIcon,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.school,
                          color: AppColors.blue,
                          size: 60,
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'KC Connect',
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Connecting Alumni & Students',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Loading Indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
