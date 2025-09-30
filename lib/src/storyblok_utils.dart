// lib/src/storyblok_utils.dart
import 'package:flutter/material.dart';
import 'storyblok_app.dart';
import 'storyblok_page.dart';
import 'storyblok_config.dart';

/// Utility functions and widgets for easier Storyblok integration

/// Simple builder function that returns a StoryblokPage for a given slug
Widget storyblokPage(String slug, {
  StoryblokVersion? version,
  Widget Function(BuildContext context, String error)? errorBuilder,
  Widget Function(BuildContext context)? loadingBuilder,
  Widget Function(BuildContext context)? emptyBuilder,
}) {
  return StoryblokPage(
    slug: slug,
    version: version,
    errorBuilder: errorBuilder,
    loadingBuilder: loadingBuilder,
    emptyBuilder: emptyBuilder,
  );
}

/// Extension on BuildContext to make SDK access easier
extension StoryblokContext on BuildContext {
  /// Get the global Storyblok provider
  GlobalStoryblokProvider get storyblok => GlobalStoryblokProvider.require(this);
  
  /// Check if we're in Storyblok editor
  bool get isInStoryblokEditor => storyblok.sdk.isInEditor;
  
  /// Get Storyblok configuration
  StoryblokConfig get storyblokConfig => storyblok.config;
}

/// Pre-built loading widget for Storyblok pages
class StoryblokLoadingWidget extends StatelessWidget {
  final String? message;

  const StoryblokLoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!),
          ]
        ],
      ),
    );
  }
}

/// Pre-built error widget for Storyblok pages
class StoryblokErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const StoryblokErrorWidget({
    super.key, 
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Unable to load content',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

/// Pre-built empty state widget for Storyblok pages
class StoryblokEmptyWidget extends StatelessWidget {
  final String? message;
  final IconData? icon;

  const StoryblokEmptyWidget({
    super.key,
    this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.article_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'No content available',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}