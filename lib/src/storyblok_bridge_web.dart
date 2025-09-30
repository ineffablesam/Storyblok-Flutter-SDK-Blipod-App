// lib/src/storyblok_bridge_web.dart
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;

import 'types.dart';

/// Web-specific implementation of Storyblok Bridge
class StoryblokBridgeImpl {
  Timer? _urlCleanupTimer;
  String? _originalUrl;
  String? _cleanPathname;
  void Function(StoryblokEventType, Map<String, dynamic>)? _eventHandler;

  /// Check if running in Storyblok editor
  bool get isInEditor {
    try {
      return html.window.self != html.window.top;
    } catch (e) {
      return false;
    }
  }

  /// Initialize the bridge for web platforms
  Future<bool> initialize(bool debug) async {
    try {
      if (debug) {
        print('[Storyblok Bridge Web] Initializing - isInEditor: $isInEditor');
      }

      if (isInEditor) {
        await _loadBridgeScript(debug);
        _setupUrlCleaning(debug);
        _setupEventListeners(debug);
      }

      return true;
    } catch (e) {
      if (debug) print('[Storyblok Bridge Web] Initialization error: $e');
      return false;
    }
  }

  /// Set the event handler callback
  void setEventHandler(void Function(StoryblokEventType, Map<String, dynamic>) handler) {
    _eventHandler = handler;
  }

  /// Load Storyblok bridge script
  Future<void> _loadBridgeScript(bool debug) async {
    final completer = Completer<void>();

    // Check if bridge is already loaded
    if (js.context.hasProperty('StoryblokBridge')) {
      if (debug) print('[Storyblok Bridge Web] Script already loaded');
      _initializeBridge(debug);
      completer.complete();
      return completer.future;
    }

    try {
      final script = html.ScriptElement()
        ..src = 'https://app.storyblok.com/f/storyblok-v2-latest.js'
        ..async = true;

      script.onLoad.listen((_) {
        if (debug) print('[Storyblok Bridge Web] Script loaded successfully');
        _initializeBridge(debug);
        completer.complete();
      });

      script.onError.listen((event) {
        if (debug) print('[Storyblok Bridge Web] Script loading failed');
        completer.completeError('Failed to load Storyblok bridge script');
      });

      html.document.head!.append(script);
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  /// Initialize bridge after script is loaded
  void _initializeBridge(bool debug) {
    if (!js.context.hasProperty('StoryblokBridge')) {
      throw Exception('StoryblokBridge not available');
    }

    try {
      final bridge = js.JsObject(js.context['StoryblokBridge']);
      js.context['sbBridge'] = bridge;

      // Setup event listeners for all Storyblok events
      for (final eventType in StoryblokEventType.values) {
        bridge.callMethod('on', [
          eventType.name,
          js.allowInterop((data) {
            _handleBridgeEvent(eventType, data, debug);
          }),
        ]);
      }

      // Special handling for viewLiveVersion
      bridge.callMethod('on', [
        'viewLiveVersion',
        js.allowInterop((_) {
          _navigateToLiveVersion(debug);
        }),
      ]);

      if (debug) {
        print('[Storyblok Bridge Web] Bridge initialized with event listeners');
      }
    } catch (e) {
      if (debug) print('[Storyblok Bridge Web] Bridge initialization error: $e');
    }
  }

  /// Handle bridge events from Storyblok editor
  void _handleBridgeEvent(StoryblokEventType eventType, dynamic data, bool debug) {
    if (debug) {
      print('[Storyblok Bridge Web] Received event: ${eventType.name}');
    }

    // Clean URL parameters after events
    _cleanStoryblokParams(debug);

    // Convert JS data to Dart Map
    Map<String, dynamic> eventData = {};
    if (data != null) {
      try {
        // Handle different types of JavaScript data
        if (data is js.JsObject) {
          // Convert JsObject to Map
          eventData = _jsObjectToMap(data);
        } else {
          // Try dartify for other types
          final dartified = js_util.dartify(data);
          if (dartified is Map) {
            eventData = Map<String, dynamic>.from(dartified);
          } else {
            eventData = {'data': dartified};
          }
        }
        
        if (debug) {
          print('[Storyblok Bridge Web] Parsed event data: ${eventData.keys.toList()}');
        }
      } catch (e) {
        if (debug) {
          print('[Storyblok Bridge Web] Error parsing event data: $e');
          print('[Storyblok Bridge Web] Raw data type: ${data.runtimeType}');
        }
        // Fallback: create empty event data
        eventData = {'error': 'Failed to parse event data'};
      }
    }

    _eventHandler?.call(eventType, eventData);
  }

  /// Convert JsObject to Map recursively
  Map<String, dynamic> _jsObjectToMap(js.JsObject jsObject) {
    final map = <String, dynamic>{};
    
    try {
      // Get all property names from the JavaScript object
      final keys = js.context['Object'].callMethod('keys', [jsObject]) as List;
      
      for (final key in keys) {
        try {
          final value = jsObject[key];
          map[key.toString()] = _convertJsValue(value);
        } catch (e) {
          map[key.toString()] = null;
        }
      }
    } catch (e) {
      // Error getting object keys
    }
    
    return map;
  }

  /// Convert JavaScript values to Dart values
  dynamic _convertJsValue(dynamic value) {
    if (value == null) return null;
    
    if (value is js.JsObject) {
      // Check if it's an array
      if (js.context['Array'].callMethod('isArray', [value])) {
        final length = value['length'] as int;
        final list = <dynamic>[];
        for (int i = 0; i < length; i++) {
          list.add(_convertJsValue(value[i]));
        }
        return list;
      } else {
        // It's an object, convert recursively
        return _jsObjectToMap(value);
      }
    }
    
    // For primitive types, return as-is
    return value;
  }

  /// Setup URL cleaning for Storyblok parameters
  void _setupUrlCleaning(bool debug) {
    try {
      final currentUri = Uri.parse(html.window.location.href);
      _originalUrl = '${currentUri.origin}${currentUri.path}';
      _cleanPathname = currentUri.path;

      if (debug) {
        print('[Storyblok Bridge Web] Setup URL cleaning - original: $_originalUrl');
      }

      _cleanStoryblokParams(debug);

      // Periodically clean URL parameters
      _urlCleanupTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        _cleanStoryblokParams(debug);
      });
    } catch (e) {
      if (debug) print('[Storyblok Bridge Web] URL cleanup setup error: $e');
    }
  }

  /// Clean Storyblok parameters from URL
  void _cleanStoryblokParams(bool debug) {
    try {
      final currentUri = Uri.parse(html.window.location.href);
      final queryParams = Map<String, String>.from(currentUri.queryParameters);

      bool hasStoryblokParams = false;
      final keysToRemove = <String>[];

      for (final key in queryParams.keys) {
        if (key.startsWith('_storyblok')) {
          keysToRemove.add(key);
          hasStoryblokParams = true;
        }
      }

      if (hasStoryblokParams) {
        for (final key in keysToRemove) {
          queryParams.remove(key);
        }

        final cleanUri = currentUri.replace(queryParameters: queryParams);
        final cleanUrl =
            cleanUri.path + (cleanUri.hasQuery ? '?${cleanUri.query}' : '');

        html.window.history.replaceState(null, '', cleanUrl);

        if (debug) {
          print('[Storyblok Bridge Web] Cleaned URL: $cleanUrl');
        }
      }
    } catch (e) {
      if (debug) print('[Storyblok Bridge Web] URL cleaning error: $e');
    }
  }

  /// Setup browser event listeners
  void _setupEventListeners(bool debug) {
    try {
      html.window.addEventListener('popstate', (event) {
        Timer(const Duration(milliseconds: 10), () => _cleanStoryblokParams(debug));
      });
    } catch (e) {
      if (debug) print('[Storyblok Bridge Web] Event listeners setup error: $e');
    }
  }

  /// Navigate to live version (outside editor)
  void _navigateToLiveVersion(bool debug) {
    if (_cleanPathname != null) {
      if (debug) {
        print('[Storyblok Bridge Web] Navigating to live version: $_cleanPathname');
      }
      _eventHandler?.call(
        StoryblokEventType.viewLiveVersion,
        {'path': _cleanPathname},
      );
    }
  }

  /// Get clean pathname for navigation
  String? get cleanPathname => _cleanPathname;

  /// Dispose bridge and clean up resources
  void dispose() {
    _urlCleanupTimer?.cancel();
    _urlCleanupTimer = null;

    if (js.context.hasProperty('sbBridge')) {
      js.context.deleteProperty('sbBridge');
    }
  }
}