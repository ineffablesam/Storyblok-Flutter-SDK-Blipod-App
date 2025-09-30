// lib/src/storyblok_sdk.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'component_registry.dart';
import 'storyblok_bridge.dart';
import 'storyblok_config.dart';
import 'types.dart';

/// Main Storyblok SDK class
class StoryblokSDK {
  static StoryblokSDK? _instance;
  static StoryblokSDK get instance => _instance ??= StoryblokSDK._();

  StoryblokSDK._();

  StoryblokConfig? _config;
  StoryblokBridge? _bridge;
  final ComponentRegistry _componentRegistry = ComponentRegistry.instance;
  final StreamController<StoryblokEvent> _eventController =
      StreamController.broadcast();

  /// Initialize the SDK
  Future<bool> initialize(StoryblokConfig config) async {
    _config = config;

    if (_config!.debug) {
      print('[Storyblok SDK] Initializing with config: ${_config!.toJson()}');
    }

    // Initialize bridge for web platforms
    if (kIsWeb) {
      _bridge = StoryblokBridge(debug: config.debug);
      final bridgeInitialized = await _bridge!.initialize();

      if (bridgeInitialized && _bridge!.isInEditor) {
        _setupBridgeEventListeners();
      }

      return bridgeInitialized;
    }

    return true;
  }

  /// Setup event listeners from the bridge
  void _setupBridgeEventListeners() {
    if (_bridge == null) return;

    for (final eventType in StoryblokEventType.values) {
      _bridge!.addEventListener(eventType, (event) {
        _eventController.add(event);

        if (_config!.debug) {
          print('[Storyblok SDK] Bridge event: ${event.type.name}');
        }
      });
    }
  }

  /// Fetch a story from Storyblok API
Future<StoryblokStory> fetchStory(
  String slug, {
  StoryblokVersion? version,
}) async {
  if (_config == null) {
    throw Exception('SDK not initialized. Call initialize() first.');
  }

  final requestVersion = version ?? _config!.version;
  final url = '${_config!.apiBaseUrl}/cdn/stories/$slug';
  final uri = Uri.parse(url).replace(
    queryParameters: {
      'token': _config!.token,
      'version': requestVersion.name,
    },
  );

  if (_config!.debug) {
    print('[Storyblok SDK] Fetching story: $slug (${requestVersion.name})');
  }

  http.Response? response;

  try {
    response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final story = StoryblokStory.fromJson(data['story']);

      if (_config!.debug) {
        print('[Storyblok SDK] Successfully fetched story: $slug');
      }

      return story;
    } else {
      final errorMessage =
          'Failed to fetch story "$slug": ${response.statusCode} ${response.reasonPhrase}\nBody: ${response.body}';
      if (_config!.debug) {
        print('[Storyblok SDK] $errorMessage');
      }
      throw Exception(errorMessage);
    }
  } catch (e) {
    if (_config!.debug) {
      print('[Storyblok SDK] Error fetching story: $e');
      if (response != null) {
        print('[Storyblok SDK] Response body: ${response.body}');
      }
    }
    rethrow;
  }
}


  /// Fetch multiple stories
  Future<List<StoryblokStory>> fetchStories({
    String? startsWith,
    String? byUuids,
    String? excludingSlugs,
    String? byUuidsOrdered,
    String? excludingIds,
    String? excludingFields,
    String? resolvingLinks,
    String? resolvingRelations,
    String? fromRelease,
    String? fallbackLang,
    String? language,
    int? perPage,
    int? page,
    String? sortBy,
    String? searchTerm,
    String? filterQuery,
    bool? isStartpage,
    String? withTag,
    StoryblokVersion? version,
  }) async {
    if (_config == null) {
      throw Exception('SDK not initialized. Call initialize() first.');
    }

    final requestVersion = version ?? _config!.version;
    final url = '${_config!.apiBaseUrl}/cdn/stories';

    final queryParams = <String, String>{
      'token': _config!.token,
      'version': requestVersion.name,
    };

    // Add optional parameters
    if (startsWith != null) queryParams['starts_with'] = startsWith;
    if (byUuids != null) queryParams['by_uuids'] = byUuids;
    if (excludingSlugs != null) queryParams['excluding_slugs'] = excludingSlugs;
    if (byUuidsOrdered != null)
      queryParams['by_uuids_ordered'] = byUuidsOrdered;
    if (excludingIds != null) queryParams['excluding_ids'] = excludingIds;
    if (excludingFields != null)
      queryParams['excluding_fields'] = excludingFields;
    if (resolvingLinks != null) queryParams['resolve_links'] = resolvingLinks;
    if (resolvingRelations != null)
      queryParams['resolve_relations'] = resolvingRelations;
    if (fromRelease != null) queryParams['from_release'] = fromRelease;
    if (fallbackLang != null) queryParams['fallback_lang'] = fallbackLang;
    if (language != null) queryParams['language'] = language;
    if (perPage != null) queryParams['per_page'] = perPage.toString();
    if (page != null) queryParams['page'] = page.toString();
    if (sortBy != null) queryParams['sort_by'] = sortBy;
    if (searchTerm != null) queryParams['search_term'] = searchTerm;
    if (filterQuery != null) queryParams['filter_query'] = filterQuery;
    if (isStartpage != null)
      queryParams['is_startpage'] = isStartpage.toString();
    if (withTag != null) queryParams['with_tag'] = withTag;

    final uri = Uri.parse(url).replace(queryParameters: queryParams);

    if (_config!.debug) {
      print('[Storyblok SDK] Fetching stories with params: $queryParams');
    }

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final storiesData = data['stories'] as List;
        final stories = storiesData
            .map((storyData) => StoryblokStory.fromJson(storyData))
            .toList();

        if (_config!.debug) {
          print(
            '[Storyblok SDK] Successfully fetched ${stories.length} stories',
          );
        }

        return stories;
      } else {
        final errorMessage =
            'Failed to fetch stories: ${response.statusCode} ${response.reasonPhrase}';
        if (_config!.debug) {
          print('[Storyblok SDK] $errorMessage');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (_config!.debug) {
        print('[Storyblok SDK] Error fetching stories: $e');
      }
      rethrow;
    }
  }

  /// Register a component builder
  void registerComponent(String name, StoryblokComponentBuilder builder) {
    _componentRegistry.register(name, builder);

    if (_config?.debug == true) {
      print('[Storyblok SDK] Registered component: $name');
    }
  }

  /// Register multiple component builders
  void registerComponents(Map<String, StoryblokComponentBuilder> components) {
    _componentRegistry.registerAll(components);

    if (_config?.debug == true) {
      print(
        '[Storyblok SDK] Registered ${components.length} components: ${components.keys.toList()}',
      );
    }
  }

  /// Get a registered component builder
  StoryblokComponentBuilder? getComponent(String name) {
    final component = _componentRegistry.get(name);

    if (component == null && _config?.debug == true) {
      print('[Storyblok SDK] Component "$name" not found in registry');
    }

    return component;
  }

  /// Check if running in Storyblok editor
  bool get isInEditor => _bridge?.isInEditor ?? false;

  /// Get event stream
  Stream<StoryblokEvent> get eventStream => _eventController.stream;

  /// Listen to specific event type
  Stream<StoryblokEvent> listenToEvent(StoryblokEventType eventType) {
    return eventStream.where((event) => event.type == eventType);
  }

  /// Get current configuration
  StoryblokConfig? get config => _config;

  /// Get component registry
  ComponentRegistry get componentRegistry => _componentRegistry;

  /// Check if SDK is initialized
  bool get isInitialized => _config != null;

  /// Get clean pathname from bridge (web only)
  String? get cleanPathname => _bridge?.cleanPathname;

  /// Dispose SDK and clean up resources
  void dispose() {
    if (_config?.debug == true) {
      print('[Storyblok SDK] Disposing SDK');
    }

    _bridge?.dispose();
    _bridge = null;
    _config = null;
    _componentRegistry.clear();

    if (!_eventController.isClosed) {
      _eventController.close();
    }

    _instance = null;
  }
}
