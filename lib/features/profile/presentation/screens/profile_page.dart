// lib/features/profile/presentation/screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/buttons/primary_button.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/alumni/presentation/widgets/alumni_profile_setup_sheet.dart';
import 'package:kc_connect/features/profile/controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Profile',
          style: AppTextStyles.subHeading.copyWith(
            color: AppColors.blue,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.blue),
            onPressed: () => Get.toNamed('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshProfile(),
        color: AppColors.blue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildProfileHeader(context, controller),
              const SizedBox(height: 32),
              _buildInfoSection(controller),
              const SizedBox(height: 24),
              _buildStatsSection(controller),
              const SizedBox(height: 24),
              _buildRewardsCard(controller),
              const SizedBox(height: 24),
              _buildActivitySection(controller),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileController controller) {
    return Obx(() => Column(
      children: [
        GestureDetector(
          onTap: controller.isUploadingPhoto ? null : controller.uploadProfilePicture,
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.red.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: controller.isUploadingPhoto
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : controller.imageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              controller.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  color: AppColors.white,
                                  size: 50),
                            ),
                          )
                        : const Icon(Icons.person,
                            color: AppColors.white, size: 50),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: AppColors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          controller.name.isEmpty ? 'KC Connect User' : controller.name,
          style: AppTextStyles.heading.copyWith(
            color: AppColors.blue,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          controller.role,
          style: AppTextStyles.body.copyWith(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          controller.institution,
          style: AppTextStyles.caption.copyWith(
            color: Colors.grey[500],
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 140,
              child: PrimaryButton(
                label: 'Edit Profile',
                onPressed: () => _showEditProfileSheet(context, controller),
                height: 40,
              ),
            ),
            if ((controller.user?['role'] as String? ?? '') == 'alumni') ...[
              const SizedBox(width: 10),
              SizedBox(
                width: 150,
                child: OutlinedButton.icon(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => const AlumniProfileSetupSheet(),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.blue),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.school_outlined,
                      color: AppColors.blue, size: 16),
                  label: Text(
                    'Alumni Info',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    ));
  }

  Widget _buildInfoSection(ProfileController controller) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Information',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.blue,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email, 'Email',
              controller.email.isEmpty ? '—' : controller.email),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone, 'Phone',
              controller.phone.isEmpty ? '—' : controller.phone),
          if (controller.level.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.school, 'Level', controller.level),
          ],
          if (controller.classYear.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, 'Class', controller.classYear),
          ],
        ],
      ),
    ));
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.blue, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(ProfileController controller) {
    return Obx(() => Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.event,
            label: 'Events',
            value: controller.myEventsCount.toString(),
            color: AppColors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.bookmark,
            label: 'Saved',
            value: controller.savedCount.toString(),
            color: AppColors.deepRed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.download,
            label: 'Downloads',
            value: controller.downloadsCount.toString(),
            color: AppColors.blue,
          ),
        ),
      ],
    ));
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.subHeading.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[600],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsCard(ProfileController controller) {
    return Obx(() {
      final pts        = controller.points;
      final net        = controller.netPoints;
      final hasClaim   = controller.hasRewardClaim;
      final toNext     = controller.pointsToNextClaim;
      final redeemed   = controller.timesRedeemed;
      final thisMonth  = controller.pointsThisMonth;
      final progress   = (net / 50).clamp(0.0, 1.0);
      final role       = controller.user?['role'] as String? ?? '';

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Rewards',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$pts pts total',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.amber[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Claim available banner OR progress bar
            if (hasClaim)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.card_giftcard, color: Colors.green, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You have a free event registration! Use it when paying for a paid event.',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$net / 50 pts to free event',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$toNext pts to go',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // This month + redeemed row
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  'This month: $thisMonth pts',
                  style: AppTextStyles.caption.copyWith(color: Colors.grey[600], fontSize: 12),
                ),
                if (redeemed > 0) ...[
                  const Spacer(),
                  Icon(Icons.redeem, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '$redeemed free event${redeemed == 1 ? '' : 's'} used',
                    style: AppTextStyles.caption.copyWith(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // How to earn points
            Text(
              role == 'alumni'
                  ? 'Earn points: free event (+5) · paid event (+10) · K-Store purchase (+5) · mentor a student (+2)'
                  : 'Earn points: free event (+5) · paid event (+10) · K-Store purchase (+5)',
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey[500],
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActivitySection(ProfileController controller) {
    return Obx(() {
      final activities = controller.recentActivity;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppColors.blue, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Recent Activity',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              Text(
                'No recent activity yet',
                style: AppTextStyles.caption.copyWith(color: Colors.grey[500]),
              )
            else
              ...activities.asMap().entries.map((entry) {
                final item = entry.value;
                return Column(
                  children: [
                    if (entry.key > 0) const SizedBox(height: 12),
                    _buildActivityItem(
                      icon: item.icon,
                      title: item.title,
                      time: item.timeAgo,
                      color: item.color,
                    ),
                  ],
                );
              }),
          ],
        ),
      );
    });
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditProfileSheet(BuildContext context, ProfileController controller) {
    AppBottomSheet.show(
      context: context,
      title: 'Edit Profile',
      child: _EditProfileForm(controller: controller),
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  final ProfileController controller;
  const _EditProfileForm({required this.controller});

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.controller.name);
    _phoneController = TextEditingController(text: widget.controller.phone);
    _bioController = TextEditingController(text: widget.controller.bio);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(
          label: 'Full Name',
          hint: 'Enter your full name',
          controller: _nameController,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Phone Number',
          hint: 'e.g. +237 6XX XXX XXX',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        AppMultilineField(
          label: 'Bio',
          hint: 'Tell us about yourself',
          controller: _bioController,
          minLines: 2,
          maxLines: 4,
        ),
        const SizedBox(height: 24),
        Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: widget.controller.isUpdating
                ? null
                : () async {
                    await widget.controller.updateProfile(
                      fullName: _nameController.text,
                      phone: _phoneController.text,
                      bio: _bioController.text,
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: widget.controller.isUpdating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        )),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
