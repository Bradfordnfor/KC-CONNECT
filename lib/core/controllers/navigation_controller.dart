import 'package:get/get.dart';

/// GetX controller for bottom navigation
class NavigationController extends GetxController {
  // Observable current index
  final _currentIndex = 0.obs;

  // Getter for current index
  int get currentIndex => _currentIndex.value;

  // Method to change page
  void changePage(int index) {
    _currentIndex.value = index;
  }

  // Reset to home page
  void goToHome() {
    _currentIndex.value = 0;
  }
}
