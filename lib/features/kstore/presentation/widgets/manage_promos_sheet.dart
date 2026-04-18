import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/models/promo_model.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/kstore/controllers/store_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────

void showManagePromosSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ManagePromosSheet(),
  );
}

// ─── Sheet wrapper (fixed height, sticky header, scrollable list) ─────────────

class _ManagePromosSheet extends StatefulWidget {
  const _ManagePromosSheet();

  @override
  State<_ManagePromosSheet> createState() => _ManagePromosSheetState();
}

class _ManagePromosSheetState extends State<_ManagePromosSheet> {
  List<PromoModel> _promos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllPromos();
  }

  Future<void> _loadAllPromos() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('store_promos')
          .select()
          .order('created_at');
      if (!mounted) return;
      setState(() {
        _promos = (response as List)
            .map((r) => PromoModel.fromJson(r as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackbar.error('Error', 'Failed to load promos');
    }
  }

  void _refreshAll() {
    _loadAllPromos();
    Get.find<StoreController>().loadPromos();
  }

  void _showForm({PromoModel? promo}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PromoFormSheet(promo: promo, onSaved: _refreshAll),
    );
  }

  void _confirmDelete(PromoModel promo) {
    Get.dialog(AlertDialog(
      title: const Text('Delete Promo?'),
      content: Text('Remove "${promo.label}" from the carousel?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            Get.back();
            try {
              await Supabase.instance.client
                  .from('store_promos')
                  .delete()
                  .eq('id', promo.id);
              _refreshAll();
              AppSnackbar.success('Deleted', 'Promo removed');
            } catch (e) {
              AppSnackbar.error('Error', 'Failed to delete promo');
            }
          },
          child: const Text('Delete', style: TextStyle(color: AppColors.red)),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Drag handle ──
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Title row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Manage Carousel Promos',
                  style: AppTextStyles.subHeading.copyWith(
                    color: AppColors.blue,
                    fontSize: 17,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Add button (sticky, always visible) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: AppColors.white),
                label: const Text(
                  'Add New Promo',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _showForm(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // ── Scrollable promo list ──
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _promos.isEmpty
                    ? Center(
                        child: Text(
                          'No promos yet.\nTap "Add New Promo" to get started.',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        itemCount: _promos.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final promo = _promos[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: AppColors.gradientColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                PromoModel.iconData(promo.iconName),
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              promo.label,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${promo.salePrice}  •  ${promo.badge}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: promo.isActive
                                        ? AppColors.success
                                            .withValues(alpha: 0.12)
                                        : Colors.grey.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    promo.isActive ? 'On' : 'Off',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: promo.isActive
                                          ? AppColors.success
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  color: AppColors.blue,
                                  onPressed: () => _showForm(promo: promo),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  color: AppColors.red,
                                  onPressed: () => _confirmDelete(promo),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Promo form (keyboard-safe bottom sheet) ──────────────────────────────────

class _PromoFormSheet extends StatefulWidget {
  final PromoModel? promo;
  final VoidCallback onSaved;

  const _PromoFormSheet({this.promo, required this.onSaved});

  @override
  State<_PromoFormSheet> createState() => _PromoFormSheetState();
}

class _PromoFormSheetState extends State<_PromoFormSheet> {
  final _labelController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  String _badge = 'NEW';
  String _iconName = 'checkroom';
  bool _isActive = true;
  bool _isSaving = false;

  String _stripPrefix(String value) =>
      value.replaceFirst(RegExp(r'^XAF\s*'), '').trim();

  String _addPrefix(String value) => 'XAF ${value.trim()}';

  @override
  void initState() {
    super.initState();
    if (widget.promo != null) {
      final p = widget.promo!;
      _labelController.text = p.label;
      _originalPriceController.text = _stripPrefix(p.originalPrice);
      _salePriceController.text = _stripPrefix(p.salePrice);
      _badge = p.badge;
      _iconName =
          PromoModel.iconMap.containsKey(p.iconName) ? p.iconName : 'checkroom';
      _isActive = p.isActive;
    }
  }

  Future<void> _save() async {
    if (_labelController.text.trim().isEmpty ||
        _originalPriceController.text.trim().isEmpty ||
        _salePriceController.text.trim().isEmpty) {
      AppSnackbar.error('Missing Fields', 'Please fill all required fields');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = {
        'label': _labelController.text.trim(),
        'original_price': _addPrefix(_originalPriceController.text),
        'sale_price': _addPrefix(_salePriceController.text),
        'badge': _badge,
        'icon_name': _iconName,
        'is_active': _isActive,
      };

      if (widget.promo == null) {
        await Supabase.instance.client.from('store_promos').insert(data);
        AppSnackbar.success('Added', 'Promo created successfully');
      } else {
        await Supabase.instance.client
            .from('store_promos')
            .update(data)
            .eq('id', widget.promo!.id);
        AppSnackbar.success('Updated', 'Promo updated successfully');
      }
      if (mounted) Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      debugPrint('Save promo error: $e');
      AppSnackbar.error('Error', 'Failed to save promo');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              widget.promo == null ? 'New Promo' : 'Edit Promo',
              style: AppTextStyles.subHeading.copyWith(
                color: AppColors.blue,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _labelController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Label *',
                hintText: 'e.g. KC T-SHIRTS',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _originalPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Original Price *',
                      hintText: '5500',
                      prefixText: 'XAF ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _salePriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sale Price *',
                      hintText: '3500',
                      prefixText: 'XAF ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: _badge,
              decoration: const InputDecoration(
                labelText: 'Badge',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              items: ['NEW', 'SALE', 'HOT', 'LIMITED']
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (v) => setState(() => _badge = v!),
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: _iconName,
              decoration: const InputDecoration(
                labelText: 'Icon',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              items: PromoModel.iconMap.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Row(children: [
                          Icon(e.value, size: 18, color: AppColors.blue),
                          const SizedBox(width: 8),
                          Text(e.key),
                        ]),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _iconName = v!),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Show in carousel', style: AppTextStyles.body),
                Switch(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  activeTrackColor: AppColors.blue,
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        widget.promo == null ? 'Add Promo' : 'Save Changes',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _originalPriceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }
}
