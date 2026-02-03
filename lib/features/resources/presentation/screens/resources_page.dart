// lib/features/resources/presentation/screens/resources_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/cards/kc_list_card.dart';
import 'package:kc_connect/core/widgets/loading_indicator.dart';
import 'package:kc_connect/core/widgets/empty_state.dart';
import 'package:kc_connect/core/widgets/error_widget.dart';
import 'package:kc_connect/features/resources/controllers/resources_controller.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ResourcesController controller = Get.put(ResourcesController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        controller.changeTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundColor,
      child: Column(
        children: [
          _buildTabBar(),
          _buildSearchAndFilter(),

          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  // Search bar with filter button
  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.backgroundColor,
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
                onChanged: (value) => controller.searchResources(value),
                decoration: InputDecoration(
                  hintText: 'Search resources...',
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
                      onPressed: () => controller.searchResources(''),
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
              final isFiltered = controller.selectedSubject != 'All';
              return IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: isFiltered ? AppColors.red : AppColors.blue,
                  size: 24,
                ),
                onPressed: () => _showFilterBottomSheet(),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Tab Bar
  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.red,
        indicatorWeight: 3,
        labelStyle: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        tabs: [
          Tab(
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('O/L'),
                  const SizedBox(width: 4),
                  _buildCountBadge(
                    controller.getResourceCountForCategory('Ordinary Level'),
                  ),
                ],
              ),
            ),
          ),
          Tab(
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('A/L'),
                  const SizedBox(width: 4),
                  _buildCountBadge(
                    controller.getResourceCountForCategory('Advanced Level'),
                  ),
                ],
              ),
            ),
          ),
          Tab(
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('OTHER'),
                  const SizedBox(width: 4),
                  _buildCountBadge(
                    controller.getResourceCountForCategory('Other Books'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.blue,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Content
  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: LoadingIndicator());
      }

      if (controller.errorMessage.isNotEmpty) {
        return ErrorDisplay(
          message: controller.errorMessage,
          onRetry: () => controller.refreshResources(),
        );
      }

      if (controller.filteredResources.isEmpty) {
        return EmptyState(
          icon: Icons.book_outlined,
          title: 'No Resources Found',
          message:
              controller.searchQuery.isNotEmpty ||
                  controller.selectedSubject != 'All'
              ? 'Try adjusting your search or filters'
              : 'No resources available in this category',
          action:
              controller.searchQuery.isNotEmpty ||
                  controller.selectedSubject != 'All'
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
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshResources(),
        color: AppColors.blue,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: controller.filteredResources.length,
          itemBuilder: (context, index) {
            final resource = controller.filteredResources[index];
            return KCListCard(
              icon: Icons.menu_book,
              title: resource.title,
              subtitle: resource.subtitle,
              meta: resource.meta,
              onTap: () => controller.downloadResource(resource),
              rightWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      resource.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: resource.isFavorite
                          ? AppColors.red
                          : AppColors.blue,
                      size: 22,
                    ),
                    onPressed: () => controller.toggleFavorite(resource.id),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.blue,
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  // Filter Bottom Sheet
  void _showFilterBottomSheet() {
    final subjects = controller.getAvailableSubjects();

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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Resources',
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

            // Subject filter
            Text(
              'Subject',
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
                children: subjects.map((subject) {
                  final isSelected = controller.selectedSubject == subject;
                  return FilterChip(
                    label: Text(subject),
                    selected: isSelected,
                    onSelected: (selected) {
                      controller.filterBySubject(subject);
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

            // Action buttons
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
