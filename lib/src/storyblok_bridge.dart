// lib/src/storyblok_bridge.dart
import 'dart:async';

// Conditional imports for platform-specific libraries
import 'storyblok_bridge_stub.dart'
    if (dart.library.html) 'storyblok_bridge_web.dart'
    if (dart.library.io) 'storyblok_bridge_io.dart';

import 'package:flutter/foundation.dart';
import 'types.dart';

/// Storyblok Bridge integration for Flutter
/// Handles communication with Storyblok Visual Editor
class StoryblokBridge {
  static StoryblokBridge? _instance;
  static StoryblokBridge get instance => _instance ??= StoryblokBridge._();

  StoryblokBridge._({bool debug = false}) : _debug = debug;

  final Map<StoryblokEventType, List<StoryblokEventCallback>> _eventListeners = {};
  bool _isInitialized = false;
  final bool _debug;
  
  // Use the platform-specific implementation
  final StoryblokBridgeImpl _impl = StoryblokBridgeImpl();

  StoryblokBridge({bool debug = false}) : _debug = debug;

  /// Check if running in Storyblok editor
  bool get isInEditor => _impl.isInEditor;

  /// Initialize the bridge
  Future<bool> initialize() async {
    if (_isInitialized) {
      if (_debug) print('[Storyblok Bridge] Already initialized');
      return true;
    }

    try {
      final success = await _impl.initialize(_debug);
      if (success) {
        _impl.setEventHandler(_handleBridgeEvent);
        _isInitialized = true;
      }
      return success;
    } catch (e) {
      if (_debug) print('[Storyblok Bridge] Initialization error: $e');
      return false;
    }
  }

  /// Handle bridge events from Storyblok editor
  void _handleBridgeEvent(StoryblokEventType eventType, Map<String, dynamic> data) {
    if (_debug) {
      print('[Storyblok Bridge] Received event: ${eventType.name}');
    }

    final event = StoryblokEvent.fromJson(eventType, data);
    _emitEvent(event);
  }

  /// Add event listener
  void addEventListener(
    StoryblokEventType eventType,
    StoryblokEventCallback callback,
  ) {
    _eventListeners.putIfAbsent(eventType, () => []).add(callback);

    if (_debug) {
      print('[Storyblok Bridge] Added listener for ${eventType.name}');
    }
  }

  /// Remove event listener
  void removeEventListener(
    StoryblokEventType eventType,
    StoryblokEventCallback callback,
  ) {
    _eventListeners[eventType]?.remove(callback);

    if (_debug) {
      print('[Storyblok Bridge] Removed listener for ${eventType.name}');
    }
  }

  /// Emit event to all listeners
  void _emitEvent(StoryblokEvent event) {
    final listeners = _eventListeners[event.type];
    if (listeners != null) {
      for (final callback in listeners) {
        try {
          callback(event);
        } catch (e) {
          if (_debug) {
            print(
              '[Storyblok Bridge] Error in event callback for ${event.type.name}: $e',
            );
          }
        }
      }
    }
  }

  /// Get clean pathname for navigation
  String? get cleanPathname => _impl.cleanPathname;

  /// Check if bridge is initialized
  bool get isInitialized => _isInitialized;

  /// Dispose bridge and clean up resources
  void dispose() {
    if (_debug) print('[Storyblok Bridge] Disposing bridge');

    _impl.dispose();
    _eventListeners.clear();
    _isInitialized = false;
  }
}