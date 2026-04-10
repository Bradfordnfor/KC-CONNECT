// lib/features/admin/presentation/screens/admin_users_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isSuperAdmin {
    final me = Get.find<AuthController>().currentUser;
    return me?['is_super_admin'] == true;
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('id, full_name, email, role, status, is_super_admin, created_at')
          .neq('status', 'inactive')
          .order('created_at', ascending: false);

      setState(() {
        _users = List<Map<String, dynamic>>.from(response as List);
        _filtered = _users;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading users: $e');
      setState(() => _isLoading = false);
      AppSnackbar.error('Error', 'Failed to load users.');
    }
  }

  void _onSearch(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = _users.where((u) {
        final name = (u['full_name'] ?? '').toString().toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        final role = (u['role'] ?? '').toString().toLowerCase();
        return name.contains(q) || email.contains(q) || role.contains(q);
      }).toList();
    });
  }

  Future<void> _suspendUser(Map<String, dynamic> user) async {
    // Double-check: only super admin can suspend admins
    if ((user['role'] as String? ?? '') == 'admin' && !_isSuperAdmin) {
      AppSnackbar.error('Unauthorized', 'Only the super admin can suspend other admins.');
      return;
    }
    try {
      await Supabase.instance.client
          .from('users')
          .update({'status': 'suspended', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', user['id']);

      setState(() {
        _users.removeWhere((u) => u['id'] == user['id']);
        _filtered.removeWhere((u) => u['id'] == user['id']);
      });
      AppSnackbar.success('Done', '${user['full_name']} has been suspended.');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to suspend user.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundColor,
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.blue))
                : _filtered.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppColors.blue,
                        onRefresh: _loadUsers,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              _buildUserCard(_filtered[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Search by name, email or role...',
          prefixIcon:
              const Icon(Icons.search, color: AppColors.blue, size: 20),
          filled: true,
          fillColor: AppColors.backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final role = (user['role'] ?? 'student') as String;
    final name = (user['full_name'] ?? 'Unknown') as String;
    final email = (user['email'] ?? '') as String;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.blue.withValues(alpha: 0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: AppTextStyles.body.copyWith(
                color: AppColors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  email,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _roleColor(role).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              role[0].toUpperCase() + role.substring(1),
              style: AppTextStyles.caption.copyWith(
                color: _roleColor(role),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Only super admin can suspend other admins
          if (!(role == 'admin' && !_isSuperAdmin))
            IconButton(
              icon: const Icon(Icons.block, color: AppColors.error, size: 20),
              tooltip: 'Suspend user',
              onPressed: () => _confirmSuspend(user),
            ),
        ],
      ),
    );
  }

  void _confirmSuspend(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Suspend User',
                  style: AppTextStyles.subHeading
                      .copyWith(color: AppColors.blue)),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to suspend ${user['full_name']}? They will no longer be able to log in.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.blue),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Cancel',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.blue)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _suspendUser(user);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Suspend',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.white)),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline,
              size: 64, color: AppColors.blue.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No users found',
              style:
                  AppTextStyles.subHeading.copyWith(color: AppColors.blue)),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
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
