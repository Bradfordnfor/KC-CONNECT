import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/common/dialog.dart';

class AdminEventsPage extends StatelessWidget {
  const AdminEventsPage({Key? key}) : super(key: key);

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
              'All Events',
              style: AppTextStyles.subHeading.copyWith(
                color: AppColors.blue,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _buildEventsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    final events = [
      {
        'title': 'Alumni Meetup 2024',
        'type': 'Social',
        'date': 'Mar 25, 2024',
        'attendees': 45,
      },
      {
        'title': 'Career Workshop',
        'type': 'Workshop',
        'date': 'Apr 2, 2024',
        'attendees': 32,
      },
      {
        'title': 'Tech Conference',
        'type': 'Conference',
        'date': 'Apr 15, 2024',
        'attendees': 78,
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = events[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event['title'] as String,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: () async {
                      final confirmed = await AppDialog.confirmDelete(
                        context: context,
                        title: 'Delete Event',
                        message:
                            'Are you sure you want to delete this event? This action cannot be undone.',
                        onConfirm: () async {
                          // TODO: Implement actual delete with Supabase
                          // await Supabase.instance.client.from('events').delete().eq('id', event['id']);
                          Navigator.pop(context);
                          // Optionally refresh events list
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event['date'] as String,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.people, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${event['attendees']} registered',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
