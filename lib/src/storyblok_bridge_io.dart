// lib/src/storyblok_bridge_io.dart
import 'dart:async';
import 'types.dart';

/// Mobile/IO implementation of Storyblok Bridge (no-op)
class StoryblokBridgeImpl {
  /// Check if running in Storyblok editor (always false on mobile)
  bool get isInEditor => false;

  /// Initialize the bridge (no-op on mobile)
  Future<bool> initialize(bool debug) async {
    if (debug) {
      print('[Storyblok Bridge IO] Bridge not available on mobile platforms');
    }
    return false;
  }

  /// Set the event handler callback (no-op on mobile)
  void setEventHandler(void Function(StoryblokEventType, Map<String, dynamic>) handler) {
    // No-op on mobile platforms
  }

  /// Get clean pathname (null on mobile)
  String? get cleanPathname => null;

  /// Dispose bridge (no-op on mobile)
  void dispose() {
    // No-op on mobile platforms
  }
}