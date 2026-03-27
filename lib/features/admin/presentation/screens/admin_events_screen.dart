import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/models/event_model.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/common/dialog.dart';
import 'package:kc_connect/core/widgets/loading_indicator.dart';
import 'package:kc_connect/core/widgets/empty_state.dart';
import 'package:kc_connect/features/admin/controllers/admin_events_controller.dart';

class AdminEventsPage extends StatelessWidget {
  const AdminEventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminEventsController());

    return Material(
      color: AppColors.backgroundColor,
      child: Obx(() {
        if (controller.isLoading) {
          return const Center(child: LoadingIndicator());
        }

        if (controller.events.isEmpty) {
          return const EmptyState(
            icon: Icons.event_busy,
            title: 'No Events',
            message: 'No events have been created yet',
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshEvents(),
          color: AppColors.blue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Events',
                  style: AppTextStyles.subHeading.copyWith(
                    color: AppColors.blue,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final event = controller.events[index];
                    return _buildEventCard(context, event, controller);
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    EventModel event,
    AdminEventsController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              Expanded(
                child: Text(
                  event.title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue,
                  ),
                ),
              ),
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.blue, size: 20),
                tooltip: 'Edit',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showEditSheet(context, event, controller),
              ),
              const SizedBox(width: 4),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                tooltip: 'Cancel event',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  await AppDialog.confirmDelete(
                    context: context,
                    title: 'Cancel Event',
                    message:
                        'Are you sure you want to cancel "${event.title}"? This cannot be undone.',
                    onConfirm: () async {
                      await controller.deleteEvent(event.id);
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                event.displayDate,
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              Icon(Icons.people, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${event.registeredCount} registered',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              // Fee badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: event.isPaid
                      ? AppColors.blue.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  event.isPaid ? 'XAF ${event.registrationFee.toStringAsFixed(0)}' : 'Free',
                  style: AppTextStyles.caption.copyWith(
                    color: event.isPaid ? AppColors.blue : AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditSheet(
    BuildContext context,
    EventModel event,
    AdminEventsController controller,
  ) {
    bool isPaid = event.isPaid;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: AppTextStyles.subHeading.copyWith(
                        color: AppColors.blue,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${event.type} · ${event.displayDate}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Paid / Free toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments_outlined, color: AppColors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paid Registration',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            isPaid ? 'XAF 500 per attendee' : 'Free to attend',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isPaid,
                      activeThumbColor: AppColors.blue,
                      onChanged: (value) => setSheetState(() => isPaid = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await controller.togglePaidStatus(event.id, isPaid);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
