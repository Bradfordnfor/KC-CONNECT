// lib/views/admin/pages/admin_users_page.dart
import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Users',
              style: AppTextStyles.subHeading.copyWith(
                color: AppColors.blue,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _buildUsersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    final users = [
      {'name': 'John Doe', 'email': 'john@example.com', 'role': 'Student'},
      {'name': 'Jane Smith', 'email': 'jane@example.com', 'role': 'Alumni'},
      {'name': 'Mike Johnson', 'email': 'mike@example.com', 'role': 'Staff'},
      {'name': 'Sarah Williams', 'email': 'sarah@example.com', 'role': 'Admin'},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.blue.withOpacity(0.1),
                child: Text(
                  user['name']![0],
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name']!,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user['email']!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor(user['role']!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user['role']!,
                  style: AppTextStyles.caption.copyWith(
                    color: _getRoleColor(user['role']!),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                onPressed: () => _showDeleteDialog(context, user['name']!),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Delete User',
                style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete $userName? This action cannot be undone.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteUser(context, userName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Delete',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteUser(BuildContext context, String userName) {
    // TODO: Implement actual delete with Supabase
    // await Supabase.instance.client.from('users').delete().eq('name', userName);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$userName has been deleted'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'staff':
        return AppColors.info;
      case 'alumni':
        return AppColors.blue;
      default:
        return AppColors.success;
    }
  }
}
