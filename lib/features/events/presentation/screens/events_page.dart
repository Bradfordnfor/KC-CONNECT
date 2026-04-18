// lib/features/events/presentation/screens/events_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/services/rewards_service.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/carousel_widget.dart';
import 'package:kc_connect/core/widgets/buttons/primary_button.dart';
import 'package:kc_connect/core/widgets/cards/kc_list_card.dart';
import 'package:kc_connect/core/widgets/common/app_fab.dart';
import 'package:kc_connect/core/widgets/loading_indicator.dart';
import 'package:kc_connect/core/widgets/empty_state.dart';
import 'package:kc_connect/core/widgets/error_widget.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:kc_connect/features/events/controllers/events_controller.dart';
import 'package:kc_connect/features/events/presentation/widgets/add_event_modal.dart';
import 'package:kc_connect/features/events/presentation/widgets/event_payment_bottom_sheet.dart';
import 'package:kc_connect/features/payment/presentation/widgets/subscription_payment_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class EventsPage extends StatelessWidget {
  EventsPage({super.key});

  final EventsController controller = Get.put(EventsController());

  // ─── Free claim prompt ───────────────────────────────────────────────────

  Future<bool?> _showFreeClaimPrompt(String eventTitle) {
    return Get.dialog<bool>(
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star, color: AppColors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Free Registration Available!',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'You have a free event registration reward. Use it for "$eventTitle"?',
                style: AppTextStyles.body.copyWith(color: Colors.grey[700], height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.blue),
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Pay Normally',
                          style: AppTextStyles.body.copyWith(color: AppColors.blue)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Use Reward',
                          style: AppTextStyles.body.copyWith(color: AppColors.white)),
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

  // ─── Shared register handler (list card + detail sheet) ──────────────────

  /// Handles the full register flow for a paid event:
  /// 1. Checks for active free claim → offers optional prompt
  /// 2. If claim used → registers free + useClaim()
  /// 3. Otherwise → opens EventPaymentBottomSheet
  Future<void> _handlePaidRegister(
    BuildContext context,
    String eventId,
    String eventName,
    double fee, {
    VoidCallback? onBeforeSheet,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final hasClaim = await RewardsService.hasActiveClaim(userId);
      if (hasClaim) {
        final useClaim = await _showFreeClaimPrompt(eventName);
        if (useClaim == true) {
          await controller.registerForEvent(eventId, paymentStatus: 'free_claim');
          await RewardsService.useClaim(userId);
          return;
        }
      }
    }
    // Pay normally
    onBeforeSheet?.call();
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => EventPaymentBottomSheet(
          eventId: eventId,
          eventName: eventName,
          price: fee.toStringAsFixed(0),
        ),
      );
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: AppColors.backgroundColor,
          child: Obx(() {
            if (controller.isLoading) {
              return const Center(child: LoadingIndicator());
            }
            if (controller.errorMessage.isNotEmpty) {
              return ErrorDisplay(
                message: controller.errorMessage,
                onRetry: controller.refreshEvents,
              );
            }
            return RefreshIndicator(
              onRefresh: controller.refreshEvents,
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
                    _buildEventsList(context),
                  ],
                ),
              ),
            );
          }),
        ),
        Positioned(
          right: 20,
          bottom: 35,
          child: Obx(() {
            final role = Get.find<AuthController>().currentUser?['role'] as String? ?? '';
            if (role != 'staff' && role != 'alumni' && role != 'admin') {
              return const SizedBox.shrink();
            }
            return AppFAB(
              onPressed: () => showAddEventModal(context),
              tooltip: 'Add Event',
            );
          }),
        ),
      ],
    );
  }

  // ─── Featured carousel ───────────────────────────────────────────────────

  Widget _buildFeaturedEventCarousel() {
    return Obx(() {
      final featured = controller.featuredEvents;
      if (featured.isEmpty) {
        return CarouselWidget(
          height: 150,
          autoPlay: false,
          showIndicators: false,
          items: [
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.gradientColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event, color: AppColors.white, size: 36),
                    const SizedBox(height: 10),
                    Text(
                      'Stay tuned for upcoming events!',
                      style: AppTextStyles.subHeading.copyWith(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
      return CarouselWidget(
        height: 150,
        autoPlay: true,
        autoPlayDuration: const Duration(seconds: 5),
        showIndicators: true,
        items: featured.map((e) => _buildFeaturedCard(e.title, e.daysToGo)).toList(),
      );
    });
  }

  Widget _buildFeaturedCard(String title, int daysToGo) {
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

  // ─── Search & filter ─────────────────────────────────────────────────────

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: controller.searchEvents,
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  hintStyle:
                      AppTextStyles.body.copyWith(color: Colors.grey[400], fontSize: 14),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.blue, size: 22),
                  suffixIcon: Obx(() {
                    if (controller.searchQuery.isEmpty) return const SizedBox.shrink();
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  isDense: true,
                ),
                style: AppTextStyles.body.copyWith(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
              style: AppTextStyles.subHeading.copyWith(color: AppColors.blue, fontSize: 20),
            ),
            Text(
              '${controller.upcomingEvents.length} events',
              style: AppTextStyles.caption.copyWith(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Events list ─────────────────────────────────────────────────────────

  Widget _buildEventsList(BuildContext context) {
    return Obx(() {
      if (controller.filteredEvents.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: EmptyState(
            icon: Icons.event_busy,
            title: 'No Events Found',
            message: controller.searchQuery.isNotEmpty ||
                    controller.selectedTypeFilter != 'All'
                ? 'Try adjusting your search or filters'
                : 'No upcoming events available',
            action: controller.searchQuery.isNotEmpty ||
                    controller.selectedTypeFilter != 'All'
                ? TextButton(
                    onPressed: controller.resetFilters,
                    child: Text(
                      'Clear Filters',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.blue, fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
          ),
        );
      }

      final currentUserId =
          Get.find<AuthController>().currentUser?['id'] as String?;

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredEvents.length,
        itemBuilder: (context, index) {
          final event = controller.filteredEvents[index];
          final isRegistered = controller.isRegistered(event.id);
          final isCreator = currentUserId != null &&
              currentUserId == event.organizedBy;

          return KCListCard(
            imageUrl: event.imageUrl,
            icon: Icons.event,
            title: event.title,
            subtitle: event.subtitle,
            meta: event.meta,
            tag: event.isOnline ? 'Online' : event.type,
            tagColor: event.isOnline ? AppColors.success : AppColors.blue,
            onTap: () => _showEventDetails(context, event),
            rightWidget: _buildCardActions(
              context: context,
              event: event,
              isRegistered: isRegistered,
              isCreator: isCreator,
            ),
          );
        },
      );
    });
  }

  Widget _buildCardActions({
    required BuildContext context,
    required event,
    required bool isRegistered,
    required bool isCreator,
  }) {
    // Creator sees Join Event (online) or nothing (onsite)
    if (isCreator) {
      if (event.isOnline && event.meetingLink != null) {
        return SizedBox(
          width: 120,
          child: ElevatedButton.icon(
            onPressed: () => _launchMeetingLink(event.meetingLink!),
            icon: const Icon(Icons.videocam, size: 14, color: AppColors.white),
            label: const Text('Join Event',
                style: TextStyle(color: AppColors.white, fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    // Non-creator: normal flow
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isRegistered && event.isOnline && event.meetingLink != null) ...[
          SizedBox(
            width: 120,
            child: ElevatedButton.icon(
              onPressed: () => _launchMeetingLink(event.meetingLink!),
              icon: const Icon(Icons.videocam, size: 14, color: AppColors.white),
              label: const Text('Join Event',
                  style: TextStyle(color: AppColors.white, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
        SizedBox(
          width: 120,
          child: PrimaryButton(
            label: isRegistered ? 'Unregister' : 'Register',
            onPressed: () async {
              if (!isRegistered && checkSubscriptionGate()) return;
              if (isRegistered) {
                controller.unregisterFromEvent(event.id);
              } else if (event.isPaid) {
                await _handlePaidRegister(
                  context,
                  event.id,
                  event.title,
                  event.registrationFee,
                );
              } else {
                controller.registerForEvent(event.id);
              }
            },
            height: 32,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          event.spotsLeft,
          style: AppTextStyles.caption.copyWith(
            color: event.isFull ? AppColors.red : Colors.grey[600],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ─── Event detail sheet ──────────────────────────────────────────────────

  void _showEventDetails(BuildContext context, event) {
    final currentUserId =
        Get.find<AuthController>().currentUser?['id'] as String?;
    final isCreator =
        currentUserId != null && currentUserId == event.organizedBy;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
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
                    style: AppTextStyles.subHeading
                        .copyWith(color: AppColors.blue, fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(sheetCtx),
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
            if (event.isOnline) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.videocam, 'Format', 'Online Event'),
            ],
            const SizedBox(height: 16),
            Text(
              'Description',
              style: AppTextStyles.body
                  .copyWith(fontWeight: FontWeight.bold, color: AppColors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: AppTextStyles.body
                  .copyWith(color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 24),
            // ── Buttons ────────────────────────────────────────────────────
            if (isCreator) ...[
              // Creator: Join if online, nothing if onsite
              if (event.isOnline && event.meetingLink != null)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchMeetingLink(event.meetingLink!),
                    icon: const Icon(Icons.videocam, color: AppColors.white),
                    label: const Text('Join Event',
                        style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
            ] else ...[
              // Non-creator: Join + Register/Unregister
              Obx(() {
                final isRegistered = controller.isRegistered(event.id);
                return Column(
                  children: [
                    if (isRegistered && event.isOnline && event.meetingLink != null) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => _launchMeetingLink(event.meetingLink!),
                          icon: const Icon(Icons.videocam, color: AppColors.white),
                          label: const Text('Join Event',
                              style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    PrimaryButton(
                      label: isRegistered ? 'Unregister' : 'Register Now',
                      expanded: true,
                      height: 48,
                      onPressed: () async {
                        if (!isRegistered && checkSubscriptionGate()) return;
                        if (isRegistered) {
                          controller.unregisterFromEvent(event.id);
                          Navigator.pop(sheetCtx);
                        } else if (event.isPaid) {
                          await _handlePaidRegister(
                            sheetCtx,
                            event.id,
                            event.title,
                            event.registrationFee,
                            onBeforeSheet: () => Navigator.pop(sheetCtx),
                          );
                        } else {
                          controller.registerForEvent(event.id);
                          Navigator.pop(sheetCtx);
                        }
                      },
                    ),
                  ],
                );
              }),
            ],
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
          style: AppTextStyles.body
              .copyWith(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body
                .copyWith(color: Colors.grey[700], fontSize: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _launchMeetingLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error', 'Could not open meeting link',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ─── Filter sheet ─────────────────────────────────────────────────────────

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
                  style: AppTextStyles.subHeading
                      .copyWith(color: AppColors.blue, fontSize: 18),
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
              style: AppTextStyles.body
                  .copyWith(fontWeight: FontWeight.bold, color: AppColors.blue),
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
                    onSelected: (_) => controller.filterByType(type),
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
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Reset',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.blue, fontWeight: FontWeight.bold),
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
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Apply',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
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
