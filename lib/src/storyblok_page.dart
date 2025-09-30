// lib/src/storyblok_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'storyblok_app.dart';
import 'storyblok_component.dart';
import 'storyblok_config.dart';
import 'types.dart';
import 'storyblok_provider.dart';

/// Simple page widget that loads and displays a Storyblok story
class StoryblokPage extends StatefulWidget {
  final String slug;
  final StoryblokVersion? version;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;

  const StoryblokPage({
    super.key,
    required this.slug,
    this.version,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
  });

  @override
  State<StoryblokPage> createState() => _StoryblokPageState();
}

class _StoryblokPageState extends State<StoryblokPage> {
  StoryblokStory? _story;
  bool _isLoading = true;
  String? _error;
  StreamSubscription<StoryblokEvent>? _eventSubscription;
  bool _hasSetupEventListeners = false;

  @override
  void initState() {
    super.initState();
    // Don't call _setupEventListeners here - it needs context with provider
    // We'll call it in didChangeDependencies instead
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Setup event listeners only once and load story
    if (!_hasSetupEventListeners) {
      _hasSetupEventListeners = true;
      _setupEventListeners();
      _loadStory();
    }
  }

  @override
  void didUpdateWidget(StoryblokPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug || oldWidget.version != widget.version) {
      _loadStory();
    }
  }

  void _setupEventListeners() {
    final provider = GlobalStoryblokProvider.require(context);
    
    // Listen for real-time updates in editor
    _eventSubscription = provider.sdk.eventStream.listen((event) {
      if (mounted) {
        switch (event.type) {
          case StoryblokEventType.input:
            if (event.story != null && event.story!.slug == widget.slug) {
              setState(() {
                _story = event.story;
              });
            }
            break;
          case StoryblokEventType.published:
            if (event.story != null && event.story!.slug == widget.slug) {
              _loadStory(); // Reload published content
            }
            break;
          default:
            break;
        }
      }
    });
  }

  Future<void> _loadStory() async {
    final provider = GlobalStoryblokProvider.require(context);
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final version = widget.version ?? provider.config.version;
      final story = await provider.sdk.fetchStory(widget.slug, version: version);
      
      if (mounted) {
        setState(() {
          _story = story;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingBuilder?.call(context) ?? 
        const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return widget.errorBuilder?.call(context, _error!) ??
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error loading story: ${widget.slug}'),
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadStory,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
    }

    if (_story?.content == null) {
      return widget.emptyBuilder?.call(context) ??
        const Center(child: Text('No content available'));
    }

    return StoryblokContent(story: _story!);
  }
}

/// Widget that renders Storyblok content with proper provider context
class StoryblokContent extends StatelessWidget {
  final StoryblokStory story;

  const StoryblokContent({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final globalProvider = GlobalStoryblokProvider.require(context);
    
    return StoryblokProvider(
      sdk: globalProvider.sdk,
      config: globalProvider.config,
      storySlug: story.slug,
      draftContent: story,
      publishedContent: story,
      isLoading: false,
      error: null,
      eventCount: 0,
      child: StoryblokComponent(content: story.content),
    );
  }
}