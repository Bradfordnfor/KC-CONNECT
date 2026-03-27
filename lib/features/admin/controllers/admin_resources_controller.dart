import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminResourcesController extends GetxController {
  final _resources = <Map<String, dynamic>>[].obs;
  final _isLoading = false.obs;

  List<Map<String, dynamic>> get resources => _resources;
  bool get isLoading => _isLoading.value;

  Map<String, dynamic>? get topResource =>
      _resources.isNotEmpty ? _resources.first : null;

  @override
  void onInit() {
    super.onInit();
    loadResources();
  }

  Future<void> loadResources() async {
    _isLoading.value = true;
    try {
      final response = await Supabase.instance.client
          .from('resources')
          .select('id, title, subject, category, download_count')
          .eq('status', 'active')
          .order('download_count', ascending: false);
      _resources.value = (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error loading admin resources: $e');
    }
    _isLoading.value = false;
  }

  Future<void> deleteResource(String id) async {
    try {
      await Supabase.instance.client
          .from('resources')
          .update({'status': 'deleted'})
          .eq('id', id);
      _resources.removeWhere((r) => r['id'] == id);
      AppSnackbar.success('Deleted', 'Resource removed successfully');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to delete resource');
    }
  }

  Future<void> refreshResources() => loadResources();
}
