import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/routes/app_routes.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Wait for animation to finish, then check auth
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      _checkAuthStatus();
    });
  }

  void _checkAuthStatus() {
    // If AuthController already resolved the session in its onInit,
    // use its state directly; otherwise fall back to the Supabase session.
    final authController = Get.find<AuthController>();
    if (authController.isAuthenticated) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        Get.offAllNamed(AppRoutes.main);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    }
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
        width: double.infinity,
        height: double.infinity,
        color: AppColors.white,
        child: Stack(
          children: [
            Positioned(
              top: -50,
              left: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blue.withValues(alpha:0.1),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.red.withValues(alpha:0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.red.withValues(alpha:0.05),
                ),
              ),
            ),
            // Decorative shapes - Bottom Right
            Positioned(
              bottom: 20,
              right: -70,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blue.withValues(alpha:0.06),
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 30,
              child: RotatedBox(
                quarterTurns: 1,
                child: Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha:0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: 40,
              child: Container(
                width: 140,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 300,
                        height: 220,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blue.withValues(alpha:0.16),
                              blurRadius: 22,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: AppColors.red.withValues(alpha:0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.white.withValues(alpha:0.3),
                            BlendMode.screen,
                          ),
                          child: Image.asset(
                            'assets/images/kc-connect_full_logo.png',
                            width: 310,
                            height: 230,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 310,
                                height: 230,
                                decoration: BoxDecoration(
                                  color: AppColors.blue.withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.school,
                                  color: AppColors.blue,
                                  size: 80,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
