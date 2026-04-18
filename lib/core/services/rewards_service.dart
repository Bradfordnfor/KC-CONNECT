// lib/core/services/rewards_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RewardsService {
  RewardsService._();

  static final _db = Supabase.instance.client;

  // ─── Award points ─────────────────────────────────────────────────────────

  /// Awards [amount] points to [userId].
  /// Increments the monthly counter, resetting it when the calendar month
  /// changes (tracked via `points_month` = "yyyy-MM").
  static Future<void> awardPoints(String userId, int amount) async {
    try {
      final row = await _db
          .from('users')
          .select('points, points_this_month, points_month')
          .eq('id', userId)
          .single();

      final current   = (row['points']           as int?    ?? 0);
      final month     = _monthKey();
      final stored    = (row['points_month']      as String? ?? '');
      final thisMonth = stored == month
          ? (row['points_this_month'] as int? ?? 0) + amount
          : amount; // new month — reset counter

      await _db.from('users').update({
        'points':           current + amount,
        'points_this_month': thisMonth,
        'points_month':      month,
      }).eq('id', userId);
    } catch (e) {
      debugPrint('RewardsService.awardPoints error: $e');
    }
  }

  // ─── Claim check ──────────────────────────────────────────────────────────

  /// Returns true when (points − reward_checkpoint) >= 50,
  /// meaning the user has an unused free-event registration.
  static Future<bool> hasActiveClaim(String userId) async {
    try {
      final row = await _db
          .from('users')
          .select('points, reward_checkpoint')
          .eq('id', userId)
          .single();
      final pts = (row['points']            as int? ?? 0);
      final cp  = (row['reward_checkpoint'] as int? ?? 0);
      return (pts - cp) >= 50;
    } catch (e) {
      debugPrint('RewardsService.hasActiveClaim error: $e');
      return false;
    }
  }

  // ─── Use claim ────────────────────────────────────────────────────────────

  /// Consumes one free-event claim:
  /// - slides reward_checkpoint forward to current points
  /// - increments times_redeemed
  /// - triggers the gift flow on every 3rd redemption (3, 6, 9 …)
  static Future<void> useClaim(String userId) async {
    try {
      final row = await _db
          .from('users')
          .select('points, times_redeemed')
          .eq('id', userId)
          .single();

      final pts         = (row['points']         as int? ?? 0);
      final newRedeemed = (row['times_redeemed']  as int? ?? 0) + 1;

      await _db.from('users').update({
        'reward_checkpoint': pts,
        'times_redeemed':    newRedeemed,
      }).eq('id', userId);

      if (newRedeemed % 3 == 0) {
        await _triggerGift(userId, newRedeemed);
      }
    } catch (e) {
      debugPrint('RewardsService.useClaim error: $e');
    }
  }

  // ─── Gift trigger ─────────────────────────────────────────────────────────

  static Future<void> _triggerGift(String userId, int timesRedeemed) async {
    try {
      // In-app congratulation modal
      Get.dialog(const _GiftRewardDialog(), barrierDismissible: false);

      // Notification to the user
      await _db.from('notifications').insert({
        'user_id':    userId,
        'title':      'You\'ve earned a gift!',
        'message':
            'Congratulations! Your consistent participation has earned you a '
            'special gift from KC Connect. Our team will reach out to you shortly.',
        'type':       'system',
        'priority':   'high',
        'is_read':    false,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Fetch user info for the admin notification
      final userRow = await _db
          .from('users')
          .select('full_name, email, phone_number, role')
          .eq('id', userId)
          .single();

      final name  = userRow['full_name']    as String? ?? 'Unknown';
      final email = userRow['email']        as String? ?? 'N/A';
      final phone = userRow['phone_number'] as String? ?? 'N/A';
      final role  = userRow['role']         as String? ?? 'N/A';

      // Notify all admins
      final admins = await _db
          .from('users')
          .select('id')
          .eq('role', 'admin');

      if ((admins as List).isNotEmpty) {
        await _db.from('notifications').insert(
          admins
              .map((a) => {
                    'user_id': a['id'] as String,
                    'title':   'Gift Reward — Action Required',
                    'message':
                        '$name ($role) has earned a gift reward '
                        '($timesRedeemed event redemptions used). '
                        'Contact: $email | $phone.',
                    'type':       'system',
                    'priority':   'high',
                    'is_read':    false,
                    'created_at': DateTime.now().toIso8601String(),
                  })
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('RewardsService._triggerGift error: $e');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static String _monthKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}';
  }
}

// ─── Gift reward modal ────────────────────────────────────────────────────────

class _GiftRewardDialog extends StatelessWidget {
  const _GiftRewardDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.gradientColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard,
                color: AppColors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You\'ve Earned a Gift!',
              style: AppTextStyles.subHeading.copyWith(
                color: AppColors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Congratulations! Your consistent participation has earned you a '
              'special gift from KC Connect. Our team will reach out to you soon!',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Awesome!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
