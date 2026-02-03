// lib/features/help/presentation/screens/help_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'How do I register for an event?',
      answer:
          'Go to the Events page, browse or search for the event you want to attend, and tap the "Register" button. You\'ll receive a confirmation notification once registered.',
    ),
    FAQItem(
      question: 'How can I download resources?',
      answer:
          'Navigate to the Resources page, select the category (O/L, A/L, or Other Books), find the resource you need, and tap on it to download. You can also save resources as favorites for quick access.',
    ),
    FAQItem(
      question: 'How do I request mentorship from an alumni?',
      answer:
          'Go to the Alumni page, find an alumni who is available for mentorship, tap on their profile, and use the "Request Mentorship" button. They will receive your request and can accept or decline.',
    ),
    FAQItem(
      question: 'Can I use KC Connect offline?',
      answer:
          'Some features like viewing downloaded resources and saved events are available offline. However, you need an internet connection to search, register for events, or message others.',
    ),
    FAQItem(
      question: 'How do I change my notification settings?',
      answer:
          'Go to Settings from the main menu, then tap on the Notifications section. You can toggle different types of notifications on or off according to your preference.',
    ),
    FAQItem(
      question: 'What should I do if I forgot my password?',
      answer:
          'On the login screen, tap "Forgot Password". Enter your registered email address, and we\'ll send you a link to reset your password.',
    ),
    FAQItem(
      question: 'How do I update my profile information?',
      answer:
          'Go to Settings, tap on "Edit Profile", and you can update your name, email, institution, and other personal information.',
    ),
    FAQItem(
      question: 'Can I sell items in the K-Store?',
      answer:
          'Currently, the K-Store is managed by KC Connect administrators. If you have items you\'d like to sell, please contact us through the "Contact Us" section.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Help & Support',
          style: AppTextStyles.subHeading.copyWith(
            color: AppColors.blue,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactCards(),
            const SizedBox(height: 24),
            _buildFAQSection(),
            const SizedBox(height: 24),
            _buildFeedbackSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTACT US',
          style: AppTextStyles.body.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: 'support@kc.com',
                color: AppColors.blue,
                onTap: () {
                  Get.snackbar(
                    'Email',
                    'Opening email client...',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildContactCard(
                icon: Icons.phone_outlined,
                title: 'Phone',
                subtitle: '+237 123 456',
                color: AppColors.deepRed,
                onTap: () {
                  Get.snackbar(
                    'Phone',
                    'Opening phone app...',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                icon: Icons.chat_bubble_outline,
                title: 'WhatsApp',
                subtitle: 'Chat with us',
                color: Colors.green,
                onTap: () {
                  Get.snackbar(
                    'WhatsApp',
                    'Opening WhatsApp...',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildContactCard(
                icon: Icons.language,
                title: 'Website',
                subtitle: 'Visit our site',
                color: AppColors.blue,
                onTap: () {
                  Get.snackbar(
                    'Website',
                    'Opening browser...',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey[600],
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FREQUENTLY ASKED QUESTIONS',
          style: AppTextStyles.body.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _faqs.asMap().entries.map((entry) {
              final index = entry.key;
              final faq = entry.value;
              return Column(
                children: [
                  _buildFAQTile(faq),
                  if (index < _faqs.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQTile(FAQItem faq) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      title: Text(
        faq.question,
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      iconColor: AppColors.blue,
      collapsedIconColor: Colors.grey[600],
      children: [
        Text(
          faq.answer,
          style: AppTextStyles.body.copyWith(
            color: Colors.grey[700],
            height: 1.5,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SEND FEEDBACK',
          style: AppTextStyles.body.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                  Icon(
                    Icons.feedback_outlined,
                    color: AppColors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Share Your Thoughts',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Help us improve KC Connect by sharing your feedback, suggestions, or reporting any issues you encounter.',
                style: AppTextStyles.body.copyWith(
                  color: Colors.grey[700],
                  height: 1.5,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showFeedbackDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Send Feedback',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();
    String selectedType = 'Feedback';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Send Feedback',
          style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Type',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                items: ['Feedback', 'Bug Report', 'Feature Request', 'Other']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedType = value!);
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Message',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: feedbackController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Tell us what you think...',
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              feedbackController.dispose();
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              if (feedbackController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter your feedback',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.red,
                  colorText: AppColors.white,
                );
                return;
              }

              feedbackController.dispose();
              Navigator.pop(context);
              Get.snackbar(
                'Thank You!',
                'Your feedback has been sent successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.blue,
                colorText: AppColors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
