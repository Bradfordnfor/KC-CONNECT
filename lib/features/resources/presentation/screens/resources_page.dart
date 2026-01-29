// lib/features/resources/presentation/screens/resources_page.dart
import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/cards/kc_list_card.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          Expanded(child: _buildTabBarView()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.red,
        labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'O/L'),
          Tab(text: 'A/L'),
          Tab(text: 'OTHER BOOKS'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildResourceList('Ordinary Level'),
        _buildResourceList('Advanced Level'),
        _buildResourceList('Other Books'),
      ],
    );
  }

  Widget _buildResourceList(String category) {
    // Mock data - replace with actual data from your backend
    final resources = List.generate(
      8,
      (i) => {
        'title': category == 'Other Books'
            ? 'Cognitive Control'
            : 'Advanced Level - Past Paper',
        'subtitle': '$category - ${i + 1} pages',
        'meta': 'Sir Bradford',
        'icon': Icons.menu_book,
      },
    );

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return KCListCard(
          icon: resource['icon'] as IconData,
          title: resource['title'] as String,
          subtitle: resource['subtitle'] as String,
          meta: resource['meta'] as String,
          onTap: () {
            // Navigate to resource detail
          },
        );
      },
    );
  }
}
