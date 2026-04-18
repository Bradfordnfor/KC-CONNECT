import 'package:flutter/material.dart';
import 'package:kc_connect/core/navigation/main_navigation.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/common/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenteesPage extends StatefulWidget {
  const MenteesPage({super.key});

  @override
  State<MenteesPage> createState() => _MenteesPageState();
}

class _MenteesPageState extends State<MenteesPage> {
  // Each entry holds both the request row and the joined student profile
  List<Map<String, dynamic>> _rows = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMentees();
  }

  Future<void> _loadMentees() async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final rows = await Supabase.instance.client
          .from('mentorship_requests')
          .select(
            'id, student_id, users!mentorship_requests_student_id_fkey(id, full_name, bio, profile_image_url, email)',
          )
          .eq('mentor_id', userId)
          .eq('status', 'accepted');

      setState(() {
        _rows = List<Map<String, dynamic>>.from(rows as List);
      });
    } catch (e) {
      debugPrint('Load mentees error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _endMentorship(int index) async {
    final row = _rows[index];
    final requestId = row['id'] as String;
    final studentId = row['student_id'] as String;
    final student = row['users'] as Map<String, dynamic>;
    final studentName = student['full_name'] as String? ?? 'the student';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'End Mentorship',
          style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
        ),
        content: Text(
          'Are you sure you want to end your mentorship with $studentName? They will be notified.',
          style: AppTextStyles.body.copyWith(color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('End Mentorship'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final me = Supabase.instance.client.auth.currentUser;
      final myProfile = await Supabase.instance.client
          .from('users')
          .select('full_name')
          .eq('id', me!.id)
          .single();
      final mentorName = myProfile['full_name'] as String? ?? 'Your mentor';

      await Supabase.instance.client
          .from('mentorship_requests')
          .update({'status': 'ended'})
          .eq('id', requestId);

      await Supabase.instance.client.from('notifications').insert({
        'user_id': studentId,
        'title': 'Mentorship Ended',
        'message':
            '$mentorName has ended their mentorship with you. You can now request mentorship from other alumni.',
        'type': 'mentorship',
        'action_type': 'mentorship_ended',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      setState(() => _rows.removeAt(index));
      AppSnackbar.info('Ended', 'Mentorship with $studentName has been ended.');
    } catch (e) {
      debugPrint('End mentorship error: $e');
      AppSnackbar.error('Error', 'Failed to end mentorship. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: MainNavigation.buildSecondaryAppBar(context, title: 'My Mentees'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.blue))
          : _rows.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadMentees,
                  color: AppColors.blue,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rows.length,
                    itemBuilder: (context, index) =>
                        _buildMenteeCard(index),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 52,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Mentees Yet',
              style: AppTextStyles.subHeading.copyWith(
                color: AppColors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you accept mentorship requests from students, they will appear here.',
              style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenteeCard(int index) {
    final row = _rows[index];
    final mentee = row['users'] as Map<String, dynamic>;
    final name = mentee['full_name'] as String? ?? 'Student';
    final bio = mentee['bio'] as String? ?? '';
    final email = mentee['email'] as String? ?? '';
    final avatarUrl = mentee['profile_image_url'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.blue.withValues(alpha: 0.12),
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'S',
                          style: AppTextStyles.subHeading.copyWith(
                            color: AppColors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                // Name + email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined,
                                size: 13, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                email,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Bio
            if (bio.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                bio,
                style: AppTextStyles.body.copyWith(
                  color: Colors.black87,
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ] else ...[
              const SizedBox(height: 6),
              Text(
                'No bio provided.',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // End Mentorship button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _endMentorship(index),
                icon: const Icon(Icons.person_remove_outlined,
                    color: AppColors.red, size: 18),
                label: Text(
                  'End Mentorship',
                  style: AppTextStyles.body.copyWith(color: AppColors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.red),
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
