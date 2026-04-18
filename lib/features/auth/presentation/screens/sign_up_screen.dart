import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/config/app_constants.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/features/auth/controllers/signup_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final SignupController controller;

  @override
  void initState() {
    super.initState();
    Get.delete<SignupController>(force: true);
    controller = Get.put(SignupController());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: controller.goToLogin,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth > 500
                    ? 400.0
                    : constraints.maxWidth;

                return Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            AppConstants.logo,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.school,
                                  color: AppColors.blue,
                                  size: 35,
                                ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Create Account',
                        style: AppTextStyles.heading.copyWith(
                          color: AppColors.blue,
                          fontSize: 26,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Name Field
                      TextFormField(
                        controller: controller.nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Phone Field
                      TextFormField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Role Dropdown
                      Obx(
                        () => DropdownButtonFormField<String>(
                          initialValue: controller.selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Role',
                            prefixIcon: const Icon(Icons.work_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                          ),
                          items: controller.roles
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => controller.changeRole(value!),
                        ),
                      ),

                      // Class dropdown — only for students
                      Obx(() {
                        if (controller.selectedRole != 'Student') {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: controller.selectedLevel.isEmpty
                                  ? null
                                  : controller.selectedLevel,
                              hint: const Text('Select your class'),
                              decoration: InputDecoration(
                                labelText: 'Class',
                                prefixIcon:
                                    const Icon(Icons.school_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: AppColors.white,
                              ),
                              items: SignupController.studentLevels
                                  .map(
                                    (lvl) => DropdownMenuItem<String>(
                                      value: lvl['value'],
                                      child: Text(lvl['label']!),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) controller.changeLevel(v);
                              },
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 16),

                      // Password Field
                      Obx(
                        () => TextFormField(
                          controller: controller.passwordController,
                          obscureText: controller.obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            helperText: 'Min. 8 characters with letters and numbers',
                            helperMaxLines: 2,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password Field
                      Obx(
                        () => TextFormField(
                          controller: controller.confirmPasswordController,
                          obscureText: controller.obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            helperText: 'Re-enter the same password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed:
                                  controller.toggleConfirmPasswordVisibility,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Info Card for Alumni/Staff/Admin (OTP required)
                      Obx(() {
                        final role = controller.selectedRole;
                        final needsOTP = role == 'Alumni' || role == 'Staff' || role == 'Admin';
                        if (!needsOTP) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: AppColors.info, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  role == 'Alumni'
                                      ? 'Alumni accounts require admin approval and OTP verification. No subscription needed.'
                                      : 'OTP verification required for ${role.toLowerCase()} accounts.',
                                  style: AppTextStyles.caption.copyWith(color: AppColors.info),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Signup Button
                      Obx(
                        () => SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: controller.isLoading
                                ? null
                                : controller.signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Sign Up',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: controller.goToLogin,
                            child: Text(
                              'Login',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
