// Dynamic page with custom error/loading handling
import 'package:flutter/material.dart';
import 'package:storyblok_flutter/storyblok_flutter.dart';

class DynamicStoryblokPage extends StatelessWidget {
  final String slug;

  const DynamicStoryblokPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(slug.toUpperCase()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StoryblokPage(
        slug: slug,
        loadingBuilder: (context) =>
            const StoryblokLoadingWidget(message: 'Loading page content...'),
        errorBuilder: (context, error) => StoryblokErrorWidget(
          error: error,
          onRetry: () {
            // Trigger page reload by rebuilding
            Navigator.of(context).pushReplacementNamed('/page/$slug');
          },
        ),
        emptyBuilder: (context) =>
            const StoryblokEmptyWidget(message: 'This page has no content yet'),
      ),
    );
  }
}
