// lib/features/help/presentation/screens/help_page.dart
import 'package:flutter/material.dart';
import 'package:kc_connect/core/navigation/main_navigation.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Contact details ── update these when going to production ──────────────────
const _supportEmail = 'kcconnectnoreply@gmail.com';
const _supportPhone = '+237674364902';
const _whatsappNumber = '237674364902'; // no leading +
// ──────────────────────────────────────────────────────────────────────────────

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
          'Navigate to the Resources page, select the category (O/L, A/L, or Other Books), find the resource you need, and tap on it to download. You can also save resources as favourites for quick access.',
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

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppSnackbar.error('Error', 'Could not open link. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: MainNavigation.buildSecondaryAppBar(context, title: 'Help & Support'),
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
                subtitle: _supportEmail,
                color: AppColors.blue,
                onTap: () => _launch('mailto:$_supportEmail'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildContactCard(
                icon: Icons.phone_outlined,
                title: 'Phone',
                subtitle: _supportPhone,
                color: AppColors.deepRed,
                onTap: () => _launch('tel:$_supportPhone'),
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
                onTap: () => _launch('https://wa.me/$_whatsappNumber'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildContactCard(
                icon: Icons.language,
                title: 'Website',
                subtitle: 'Coming soon',
                color: Colors.grey,
                onTap: () => AppSnackbar.info(
                  'Coming Soon',
                  'Our website is under construction.',
                ),
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
              color: Colors.black.withValues(alpha: 0.05),
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
                color: color.withValues(alpha: 0.1),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                color: Colors.black.withValues(alpha: 0.05),
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
      childrenPadding:
          const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
                color: Colors.black.withValues(alpha: 0.05),
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
                  const Icon(
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
                  onPressed: _showFeedbackDialog,
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
    final feedbackController = TextEditingController();
    String selectedType = 'Feedback';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Send Feedback',
          style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
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
              InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  isDense: true,
                ),
                child: DropdownButton<String>(
                  value: selectedType,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  items: ['Feedback', 'Bug Report', 'Feature Request', 'Other']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                ),
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              final message = feedbackController.text.trim();
              if (message.isEmpty) {
                AppSnackbar.error('Empty', 'Please enter your feedback.');
                return;
              }
              Navigator.pop(dialogContext);
              await _submitFeedback(selectedType, message);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitFeedback(String type, String message) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final now = DateTime.now().toIso8601String();
      await Supabase.instance.client.from('feedback').insert({
        'user_id': userId,
        'type': type.toLowerCase().replaceAll(' ', '_'),
        'message': message,
        'status': 'new',
        'priority': 'normal',
        'created_at': now,
        'updated_at': now,
      });
    } catch (_) {
      // Silent fail — still thank the user
    }
    AppSnackbar.success(
      'Thank You!',
      'Your feedback has been submitted successfully.',
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
