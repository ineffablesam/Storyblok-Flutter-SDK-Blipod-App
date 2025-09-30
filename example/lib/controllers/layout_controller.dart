import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class LayoutController extends GetxController {
  // bottom nav state
  final currentIndex = 0.obs;
  final previousIndex = 0.obs;

  static const double kMinHeight = 70.0;
  static const double kMaxHeight = 400.0;

  final playerHeightNotifier = ValueNotifier<double>(kMinHeight);

  void changeTab(int index) {
    previousIndex.value = currentIndex.value;
    currentIndex.value = index;
  }

  bool get isReverse => currentIndex.value < previousIndex.value;

  // change between page
  void goToPage(int index) {
    if (index == currentIndex.value) return;
    changeTab(index);
  }

  /// Push to audio page via GoRouter
  void pushToAudioPage(BuildContext context) {
    context.go('/');
    changeTab(1);
  }
}
