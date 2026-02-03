// lib/features/events/presentation/screens/events_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/carousel_widget.dart';
import 'package:kc_connect/core/widgets/buttons/primary_button.dart';
import 'package:kc_connect/core/widgets/cards/kc_list_card.dart';
import 'package:kc_connect/core/widgets/loading_indicator.dart';
import 'package:kc_connect/core/widgets/empty_state.dart';
import 'package:kc_connect/core/widgets/error_widget.dart';
import 'package:kc_connect/features/events/controllers/events_controller.dart';

class EventsPage extends StatelessWidget {
  EventsPage({super.key});

  final EventsController controller = Get.put(EventsController());

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundColor,
      child: Obx(() {
        if (controller.isLoading) {
          return const Center(child: LoadingIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return ErrorDisplay(
            message: controller.errorMessage,
            onRetry: () => controller.refreshEvents(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshEvents(),
          color: AppColors.blue,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildFeaturedEventCarousel(),
                const SizedBox(height: 24),
                _buildSearchAndFilter(),
                const SizedBox(height: 16),
                _buildUpcomingEventsHeader(),
                const SizedBox(height: 12),
                _buildEventsList(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFeaturedEventCarousel() {
    return Obx(() {
      if (controller.featuredEvents.isEmpty) {
        return const SizedBox.shrink();
      }

      return CarouselWidget(
        height: 150,
        autoPlay: true,
        autoPlayDuration: const Duration(seconds: 5),
        showIndicators: true,
        items: controller.featuredEvents.map((event) {
          return _buildFeaturedEventCard(event.title, event.daysToGo);
        }).toList(),
      );
    });
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
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: AppTextStyles.subHeading.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => controller.searchEvents(value),
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.blue,
                    size: 22,
                  ),
                  suffixIcon: Obx(() {
                    if (controller.searchQuery.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => controller.searchEvents(''),
                    );
                  }),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 0,
                  ),
                  isDense: true,
                ),
                style: AppTextStyles.body.copyWith(fontSize: 14),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Filter button
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() {
              final isFiltered = controller.selectedTypeFilter != 'All';
              return IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: isFiltered ? AppColors.red : AppColors.blue,
                  size: 24,
                ),
                onPressed: () => _showFilterBottomSheet(Get.context!),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Events',
              style: AppTextStyles.subHeading.copyWith(
                color: AppColors.blue,
                fontSize: 20,
              ),
            ),
            Text(
              '${controller.upcomingEvents.length} events',
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return Obx(() {
      if (controller.filteredEvents.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: EmptyState(
            icon: Icons.event_busy,
            title: 'No Events Found',
            message:
                controller.searchQuery.isNotEmpty ||
                    controller.selectedTypeFilter != 'All'
                ? 'Try adjusting your search or filters'
                : 'No upcoming events available',
            action:
                controller.searchQuery.isNotEmpty ||
                    controller.selectedTypeFilter != 'All'
                ? TextButton(
                    onPressed: () => controller.resetFilters(),
                    child: Text(
                      'Clear Filters',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredEvents.length,
        itemBuilder: (context, index) {
          final event = controller.filteredEvents[index];
          final isRegistered = controller.isRegistered(event.id);

          return KCListCard(
            imageUrl: event.imageUrl,
            icon: Icons.event,
            title: event.title,
            subtitle: event.subtitle,
            meta: event.meta,
            tag: event.type,
            tagColor: AppColors.blue,
            onTap: () => _showEventDetails(Get.context!, event),
            rightWidget: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 120,
                  child: PrimaryButton(
                    label: isRegistered ? 'Unregister' : 'Register',
                    onPressed: () {
                      if (isRegistered) {
                        controller.unregisterFromEvent(event.id);
                      } else {
                        controller.registerForEvent(event.id);
                      }
                    },
                    height: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.spotsLeft,
                  style: AppTextStyles.caption.copyWith(
                    color: event.isFull ? AppColors.red : Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  void _showEventDetails(BuildContext context, event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
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
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.calendar_today, 'Date', event.displayDate),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.access_time, 'Time', event.time),
            if (event.host != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.person, 'Host', event.host!),
            ],
            if (event.location != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.location_on, 'Location', event.location!),
            ],
            const SizedBox(height: 16),
            Text(
              'Description',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: AppTextStyles.body.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Obx(() {
              final isRegistered = controller.isRegistered(event.id);
              return PrimaryButton(
                label: isRegistered ? 'Unregister' : 'Register Now',
                expanded: true,
                height: 48,
                onPressed: () {
                  if (isRegistered) {
                    controller.unregisterFromEvent(event.id);
                  } else {
                    controller.registerForEvent(event.id);
                  }
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.blue, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Events',
                  style: AppTextStyles.subHeading.copyWith(
                    color: AppColors.blue,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Event Type',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.eventTypes.map((type) {
                  final isSelected = controller.selectedTypeFilter == type;
                  final count = controller.getEventCountByType(type);
                  return FilterChip(
                    label: Text('$type ($count)'),
                    selected: isSelected,
                    onSelected: (selected) {
                      controller.filterByType(type);
                    },
                    backgroundColor: AppColors.backgroundColor,
                    selectedColor: AppColors.blue,
                    labelStyle: AppTextStyles.body.copyWith(
                      color: isSelected ? AppColors.white : AppColors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    checkmarkColor: AppColors.white,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.resetFilters();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Reset',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Apply',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}
