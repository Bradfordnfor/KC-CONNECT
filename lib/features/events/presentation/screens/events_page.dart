// lib/features/events/presentation/screens/events_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/carousel_widget.dart';
import 'package:kc_connect/core/widgets/buttons/primary_button.dart';
import 'package:kc_connect/core/widgets/cards/kc_list_card.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  // Mock data - replace with Supabase data later
  final List<Map<String, dynamic>> events = [
    {
      'id': '1',
      'title': 'Talk: Cognitive Control',
      'subtitle': 'November,23rd - 2:00pm',
      'meta': 'Host: Sir Caleb',
      'imageUrl': 'assets/images/kc-connect_icon.png',
      'description':
          'A deep dive into cognitive control mechanisms and their applications in daily life.',
    },
    {
      'id': '2',
      'title': 'Talk: Cognitive Control',
      'subtitle': 'November,23rd - 2:00pm',
      'meta': 'Host: Sir Caleb',
      'imageUrl': 'assets/images/kc-connect_icon.png',
      'description':
          'Understanding cognitive processes and mental control strategies.',
    },
    {
      'id': '3',
      'title': 'Talk: Cognitive Control',
      'subtitle': 'November,23rd - 2:00pm',
      'meta': 'Host: Sir Caleb',
      'imageUrl': 'assets/images/kc-connect_icon.png',
      'description':
          'Learn how to improve focus and decision-making abilities.',
    },
    {
      'id': '4',
      'title': 'Talk: Cognitive Control',
      'subtitle': 'November,23rd - 2:00pm',
      'meta': 'Host: Sir Caleb',
      'imageUrl': 'assets/images/kc-connect_icon.png',
      'description':
          'Learn how to improve focus and decision-making abilities.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundColor,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildFeaturedEventCarousel(),
                  const SizedBox(height: 24),
                  _buildUpcomingEventsHeader(),
                  const SizedBox(height: 12),
                  _buildEventsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedEventCarousel() {
    return CarouselWidget(
      height: 150,
      autoPlay: true,
      autoPlayDuration: const Duration(seconds: 5),
      showIndicators: true,
      items: [
        _buildFeaturedEventCard('NATIONAL STEM QUEST', 29),
        _buildFeaturedEventCard('Tech Innovation Summit', 45),
        _buildFeaturedEventCard('Science Fair 2025', 60),
      ],
    );
  }

  Widget _buildFeaturedEventCard(String title, int daysToGo) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.gradientColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Days countdown
          Text(
            daysToGo.toString(),
            style: AppTextStyles.heading.copyWith(
              color: AppColors.white,
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'DAYS TO GO',
            style: AppTextStyles.body.copyWith(
              color: AppColors.white,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Event title
          Text(
            title,
            style: AppTextStyles.subHeading.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Upcoming Events',
            style: AppTextStyles.subHeading.copyWith(
              color: AppColors.blue,
              fontSize: 20,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.blue),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return KCListCard(
          imageUrl: event['imageUrl'] as String? ?? '',
          icon: Icons.event,
          title: event['title'] as String? ?? '',
          subtitle: event['subtitle'] as String? ?? '',
          meta: event['meta'] as String? ?? '',
          tag: 'Event',
          tagColor: AppColors.blue,
          onTap: () {
            _showEventDescription(event);
          },
          rightWidget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 100,
                child: PrimaryButton(
                  label: 'Register',
                  onPressed: () {
                    _showRegistrationDialog();
                  },
                  height: 32,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 100,
                child: PrimaryButton(
                  label: 'Details',
                  onPressed: () {
                    _showEventDescription(event);
                  },
                  height: 32,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRegistrationDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.blue,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Registration Successful!',
                style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You have been registered for this event. Check your email for confirmation.',
                style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'OK',
                onPressed: () => Get.back(),
                expanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDescription(Map<String, dynamic> event) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event['title'] as String? ?? 'Event',
                      style: AppTextStyles.subHeading.copyWith(
                        color: AppColors.blue,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Date: ${event['subtitle'] as String? ?? ''}',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                event['meta'] as String? ?? '',
                style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Text(
                'Details',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event['details'] as String? ?? 'No description available.',
                style: AppTextStyles.body.copyWith(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Register',
                onPressed: () {
                  Get.back();
                  _showRegistrationDialog();
                },
                expanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
