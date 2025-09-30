// lib/src/storyblok_bridge_stub.dart
import 'dart:async';
import 'types.dart';

/// Stub implementation of Storyblok Bridge (fallback)
class StoryblokBridgeImpl {
  /// Check if running in Storyblok editor (always false in stub)
  bool get isInEditor => false;

  /// Initialize the bridge (no-op in stub)
  Future<bool> initialize(bool debug) async {
    if (debug) {
      print('[Storyblok Bridge Stub] Bridge not available on this platform');
    }
    return false;
  }

  /// Set the event handler callback (no-op in stub)
  void setEventHandler(void Function(StoryblokEventType, Map<String, dynamic>) handler) {
    // No-op in stub implementation
  }

  /// Get clean pathname (null in stub)
  String? get cleanPathname => null;

  /// Dispose bridge (no-op in stub)
  void dispose() {
    // No-op in stub implementation
  }
}