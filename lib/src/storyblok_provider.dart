// lib/src/storyblok_provider.dart
import 'dart:async';

import 'package:flutter/widgets.dart';

import 'storyblok_config.dart';
import 'storyblok_sdk.dart';
import 'types.dart';

/// Provider widget for Storyblok integration
class StoryblokProvider extends InheritedWidget {
  final StoryblokSDK sdk;
  final StoryblokConfig config;
  final String? storySlug;
  final StoryblokStory? draftContent;
  final StoryblokStory? publishedContent;
  final bool isLoading;
  final String? error;
  final int eventCount;

  const StoryblokProvider({
    super.key,
    required this.sdk,
    required this.config,
    required super.child,
    this.storySlug,
    this.draftContent,
    this.publishedContent,
    this.isLoading = false,
    this.error,
    this.eventCount = 0,
  });

  /// Get the current content based on editor mode
  StoryblokStory? get currentContent {
    return sdk.isInEditor ? draftContent : publishedContent;
  }

  @override
  bool updateShouldNotify(StoryblokProvider oldWidget) {
    return draftContent != oldWidget.draftContent ||
        publishedContent != oldWidget.publishedContent ||
        isLoading != oldWidget.isLoading ||
        error != oldWidget.error ||
        eventCount != oldWidget.eventCount;
  }

  /// Get the provider from context
  static StoryblokProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<StoryblokProvider>();
  }

  /// Get the provider from context (throws if not found)
  static StoryblokProvider require(BuildContext context) {
    final provider = of(context);
    if (provider == null) {
      throw FlutterError(
        'StoryblokProvider.require was called with a context that does not contain a StoryblokProvider.\n'
        'Ensure that StoryblokProvider is an ancestor of the widget that calls StoryblokProvider.require.',
      );
    }
    return provider;
  }
}

/// Stateful wrapper that manages Storyblok state
class StoryblokProviderWrapper extends StatefulWidget {
  final StoryblokConfig config;
  final String storySlug;
  final Map<String, StoryblokComponentBuilder>? components;
  final Widget child;
  final void Function(String error)? onError;

  const StoryblokProviderWrapper({
    super.key,
    required this.config,
    required this.storySlug,
    required this.child,
    this.components,
    this.onError,
  });

  @override
  State<StoryblokProviderWrapper> createState() =>
      _StoryblokProviderWrapperState();
}

class _StoryblokProviderWrapperState extends State<StoryblokProviderWrapper> {
  late StoryblokSDK _sdk;
  StoryblokStory? _draftContent;
  StoryblokStory? _publishedContent;
  bool _isLoading = true;
  String? _error;
  int _eventCount = 0;
  StreamSubscription<StoryblokEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _initializeSDK();
  }

  Future<void> _initializeSDK() async {
    _sdk = StoryblokSDK.instance;

    try {
      await _sdk.initialize(widget.config);

      // Register components if provided
      if (widget.components != null) {
        _sdk.registerComponents(widget.components!);
      }

      // Setup event listeners
      _eventSubscription = _sdk.eventStream.listen(_handleStoryblokEvent);

      // Load initial content
      await _refreshContent();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      widget.onError?.call(e.toString());
    }
  }

  void _handleStoryblokEvent(StoryblokEvent event) {
    if (mounted) {
      setState(() {
        _eventCount++;
      });

      switch (event.type) {
        case StoryblokEventType.input:
          if (event.story != null) {
            setState(() {
              _draftContent = event.story;
            });
          }
          break;

        case StoryblokEventType.published:
          _refreshContent();
          break;

        default:
          // Handle other events as needed
          break;
      }
    }
  }

  Future<void> _refreshContent() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final futures = await Future.wait([
        _sdk
            .fetchStory(widget.storySlug, version: StoryblokVersion.draft)
            .catchError((e) => null),
        _sdk
            .fetchStory(widget.storySlug, version: StoryblokVersion.published)
            .catchError((e) => null),
      ]);

      setState(() {
        _draftContent = futures[0];
        _publishedContent = futures[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      widget.onError?.call(e.toString());
    }
  }

  @override
  void didUpdateWidget(StoryblokProviderWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.storySlug != widget.storySlug) {
      _refreshContent();
    }

    if (oldWidget.components != widget.components &&
        widget.components != null) {
      _sdk.registerComponents(widget.components!);
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoryblokProvider(
      sdk: _sdk,
      config: widget.config,
      storySlug: widget.storySlug,
      draftContent: _draftContent,
      publishedContent: _publishedContent,
      isLoading: _isLoading,
      error: _error,
      eventCount: _eventCount,
      child: widget.child,
    );
  }
}
