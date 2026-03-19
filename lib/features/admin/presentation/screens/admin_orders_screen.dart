import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({Key? key}) : super(key: key);

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
              'Recent Orders',
              style: AppTextStyles.subHeading.copyWith(
                color: AppColors.blue,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _buildOrdersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    final orders = [
      {
        'id': '#12345',
        'product': 'KC Uniform (Size M)',
        'customer': 'John Doe',
        'amount': 15000,
        'status': 'Pending',
        'date': '2 hours ago',
      },
      {
        'id': '#12344',
        'product': 'Textbook Set',
        'customer': 'Jane Smith',
        'amount': 25000,
        'status': 'Completed',
        'date': '1 day ago',
      },
      {
        'id': '#12343',
        'product': 'Calculator',
        'customer': 'Mike Johnson',
        'amount': 8000,
        'status': 'Shipped',
        'date': '2 days ago',
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
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
                  Text(
                    order['id'] as String,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.blue,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        order['status'] as String,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order['status'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: _getStatusColor(order['status'] as String),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order['product'] as String,
                style: AppTextStyles.body.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Customer: ${order['customer']}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${order['amount']} XAF',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    order['date'] as String,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'shipped':
        return AppColors.info;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}
