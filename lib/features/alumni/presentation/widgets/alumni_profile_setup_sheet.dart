// lib/features/alumni/presentation/widgets/alumni_profile_setup_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlumniProfileSetupSheet extends StatefulWidget {
  const AlumniProfileSetupSheet({super.key});

  @override
  State<AlumniProfileSetupSheet> createState() =>
      _AlumniProfileSetupSheetState();
}

class _AlumniProfileSetupSheetState extends State<AlumniProfileSetupSheet> {
  final _formKey = GlobalKey<FormState>();

  // Maps directly to what the UI displays
  final _bioController = TextEditingController();        // bio section
  final _careerController = TextEditingController();     // career section
  final _visionController = TextEditingController();     // vision section
  final _fieldController = TextEditingController();      // card "role" line  → current_position
  final _institutionController = TextEditingController(); // card "school" line → school
  final _expertiseController = TextEditingController();  // for search/filter
  final _graduationYearController = TextEditingController(); // optional
  final _maxMenteesController = TextEditingController(text: '3');

  bool _availableForMentorship = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  void _prefill() {
    final user = Get.find<AuthController>().currentUser;
    if (user == null) return;

    _bioController.text = user['bio'] ?? '';
    _careerController.text = user['career'] ?? '';
    _visionController.text = user['vision'] ?? '';
    _fieldController.text = user['current_position'] ?? '';
    _institutionController.text = user['school'] ?? '';
    _availableForMentorship = user['available_for_mentorship'] ?? true;
    _maxMenteesController.text = (user['max_mentees'] ?? 3).toString();

    final gradYear = user['graduation_year'];
    if (gradYear != null) {
      _graduationYearController.text = gradYear.toString();
    }

    final expertise = user['expertise'];
    if (expertise is List) {
      _expertiseController.text = expertise.join(', ');
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _careerController.dispose();
    _visionController.dispose();
    _fieldController.dispose();
    _institutionController.dispose();
    _expertiseController.dispose();
    _graduationYearController.dispose();
    _maxMenteesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final expertiseRaw = _expertiseController.text.trim();
      final expertiseList = expertiseRaw.isEmpty
          ? <String>[]
          : expertiseRaw.split(',').map((e) => e.trim()).toList();

      final maxMentees = int.tryParse(_maxMenteesController.text.trim()) ?? 3;

      final gradYearStr = _graduationYearController.text.trim();
      final gradYear = gradYearStr.isEmpty ? null : int.tryParse(gradYearStr);

      await Supabase.instance.client.from('users').update({
        'bio': _bioController.text.trim(),
        'career': _careerController.text.trim(),
        'vision': _visionController.text.trim(),
        'current_position': _fieldController.text.trim(),
        'school': _institutionController.text.trim(),
        'available_for_mentorship': _availableForMentorship,
        'max_mentees': maxMentees,
        'expertise': expertiseList,
        if (gradYear != null) 'graduation_year': gradYear,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      await Get.find<AuthController>().refreshProfile();

      if (mounted) Navigator.pop(context);
      AppSnackbar.success('Saved', 'Your alumni profile has been updated.');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to save profile. Try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      color: AppColors.blue, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Complete Your Alumni Profile',
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
              Text(
                'This information appears on your public alumni profile.',
                style: AppTextStyles.caption
                    .copyWith(color: Colors.grey[600], height: 1.4),
              ),
              const SizedBox(height: 20),

              // ── Field / Role ──────────────────────────────────────────
              _label('Field / Role'),
              _hint(
                'What is your field of study or profession? '
                'e.g. "Mechanical Engineering Graduate", "Nursing Student", '
                '"Computer Science PhD Candidate"',
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _fieldController,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: _deco('e.g. Mechanical Engineering Graduate'),
              ),
              const SizedBox(height: 16),

              // ── Institution & Country ──────────────────────────────────
              _label('Current Institution & Country'),
              _hint(
                'The university, company, or organisation you are currently '
                'affiliated with, and the country. '
                'e.g. "University of Buea, Cameroon", "ALU, Rwanda", '
                '"Carnegie Mellon Africa, Rwanda"',
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _institutionController,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: _deco('e.g. ALU, Rwanda'),
              ),
              const SizedBox(height: 16),

              // ── Graduation Year (optional) ────────────────────────────
              _label('Year you graduated from KC (optional)'),
              _hint(
                'The year you completed your final year at KC. '
                'Leave blank if you prefer not to share. '
                'e.g. "2021"',
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _graduationYearController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _deco('e.g. 2021'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // optional
                  final y = int.tryParse(v.trim());
                  if (y == null || y < 1950 || y > DateTime.now().year) {
                    return 'Enter a valid year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Bio ───────────────────────────────────────────────────
              _label('Bio'),
              _hint(
                'Write 2–4 sentences about who you are. Mention your KC '
                'experience, clubs you joined, what drives you, and what '
                'you are passionate about. '
                'e.g. "I\'m a software engineer who was part of the KC ICT '
                'Club. I love building products that solve real African '
                'problems…"',
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Bio is required' : null,
                decoration: _deco(
                  'I\'m a passionate engineer who was part of the KC Science '
                  'Club. I believe in using technology to…',
                ),
              ),
              const SizedBox(height: 16),

              // ── Career ────────────────────────────────────────────────
              _label('Career'),
              _hint(
                'Describe your current career situation in your own words. '
                'If you are a student: "I am currently studying X at Y." '
                'If you are working: "I am a [title] at [company], where I…" '
                'You can mention previous experience too.',
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _careerController,
                maxLines: 4,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Career info is required'
                    : null,
                decoration: _deco(
                  'I am currently a Full Stack Developer at INOFIXZ, '
                  'where I lead a team building online learning platforms…',
                ),
              ),
              const SizedBox(height: 16),

              // ── Vision ───────────────────────────────────────────────
              _label('Vision'),
              _hint(
                'What do you want to achieve in 5–10 years? What impact '
                'do you want to have on your community, country, or the world? '
                'Be bold and specific. '
                'e.g. "To become a leading AI researcher in Africa and build '
                'tools that improve healthcare for 1 million people by 2035."',
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _visionController,
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Vision is required'
                    : null,
                decoration: _deco(
                  'To build Africa\'s largest ed-tech platform and make '
                  'quality education accessible to every student…',
                ),
              ),
              const SizedBox(height: 16),

              // ── Expertise / Mentorship Areas ──────────────────────────
              _label('Expertise / Mentorship Areas'),
              _hint(
                'List the specific topics or skills you can mentor students '
                'in. These appear as tags on your profile and help students '
                'find you. Separate each with a comma. '
                'e.g. "Flutter, Python, Data Science, CV Writing, '
                'Scholarship Applications, Leadership"',
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _expertiseController,
                decoration: _deco(
                  'e.g. Flutter, Python, Data Science, CV Writing',
                ),
              ),
              const SizedBox(height: 16),

              // Mentorship settings
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available for Mentorship',
                                style: AppTextStyles.body
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Students can send you requests',
                                style: AppTextStyles.caption
                                    .copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _availableForMentorship,
                          onChanged: (v) =>
                              setState(() => _availableForMentorship = v),
                          activeThumbColor: AppColors.blue,
                        ),
                      ],
                    ),
                    if (_availableForMentorship) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Max mentees at a time',
                              style: AppTextStyles.body
                                  .copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: TextFormField(
                              controller: _maxMenteesController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (!_availableForMentorship) return null;
                                final n = int.tryParse(v ?? '');
                                if (n == null || n < 1) return 'Min 1';
                                return null;
                              },
                              decoration: _deco('3').copyWith(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Save Profile',
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
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: AppTextStyles.body
            .copyWith(fontWeight: FontWeight.w600, fontSize: 13),
      );

  Widget _hint(String text) => Text(
        text,
        style: AppTextStyles.caption
            .copyWith(color: Colors.grey[500], fontSize: 11),
      );

  InputDecoration _deco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            AppTextStyles.body.copyWith(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: AppColors.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
}
