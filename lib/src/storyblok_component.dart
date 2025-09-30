// lib/src/storyblok_component.dart
import 'package:flutter/material.dart';

import 'storyblok_provider.dart';
import 'storyblok_editable.dart';
import 'types.dart';

/// Widget that renders Storyblok content using registered components
class StoryblokComponent extends StatelessWidget {
  final Map<String, dynamic> content;
  final String? componentKey;

  const StoryblokComponent({
    super.key,
    required this.content,
    this.componentKey,
  });

  @override
  Widget build(BuildContext context) {
    final provider = StoryblokProvider.require(context);
    return _renderContent(context, provider, content, componentKey);
  }

  Widget _renderContent(
    BuildContext context,
    StoryblokProvider provider,
    dynamic content,
    String? key,
  ) {
    if (content == null) {
      return const SizedBox.shrink();
    }

    // Handle arrays of content
    if (content is List) {
      return Column(
        key: key != null ? Key(key) : null,
        children: content
            .asMap()
            .entries
            .map(
              (entry) => _renderContent(
                context,
                provider,
                entry.value,
                '${key ?? 'item'}-${entry.key}',
              ),
            )
            .toList(),
      );
    }

    // Handle individual bloks (components)
    if (content is Map<String, dynamic> && content.containsKey('component')) {
      final blok = StoryblokBlok.fromJson(content);
      final componentBuilder = provider.sdk.getComponent(blok.component);

      if (componentBuilder != null) {
        // Build props map for the component
        final props = <String, dynamic>{
          ...blok.content,
          'blok': content,
          '_editable': blok.editable,
        };

        try {
          return componentBuilder(context, blok, props);
        } catch (e) {
          if (provider.config.debug) {
            print(
              '[Storyblok Component] Error rendering ${blok.component}: $e',
            );
          }
          return _buildErrorWidget(blok.component, e.toString());
        }
      } else {
        // Handle built-in components automatically
        final builtInWidget = _renderBuiltInComponent(context, provider, blok);
        if (builtInWidget != null) {
          return builtInWidget;
        }
        
        // Component not found - render placeholder
        if (provider.config.debug) {
          print(
            '[Storyblok Component] Component "${blok.component}" not registered',
          );
        }
        return _buildMissingComponentWidget(blok.component);
      }
    }

    // Handle nested objects with potential components
    if (content is Map<String, dynamic>) {
      final renderedContent = <String, dynamic>{};

      content.forEach((key, value) {
        if (value is List &&
            value.any((item) => item is Map && item.containsKey('component'))) {
          renderedContent[key] = _renderContent(context, provider, value, key);
        } else if (value is Map && value.containsKey('component')) {
          renderedContent[key] = _renderContent(context, provider, value, key);
        } else {
          renderedContent[key] = value;
        }
      });

      // If no components were rendered, return empty widget
      if (renderedContent.values.every((value) => value is! Widget)) {
        return const SizedBox.shrink();
      }

      // Return the first rendered widget found, or combine them
      final widgets = renderedContent.values.whereType<Widget>().toList();
      if (widgets.isEmpty) {
        return const SizedBox.shrink();
      }

      return widgets.length == 1 ? widgets.first : Column(children: widgets);
    }

    return const SizedBox.shrink();
  }

  /// Handle built-in components that don't need explicit registration
  Widget? _renderBuiltInComponent(BuildContext context, StoryblokProvider provider, StoryblokBlok blok) {
    switch (blok.component) {
      case 'page':
        return _renderPageComponent(context, provider, blok);
      case 'text':
        return _renderTextComponent(context, provider, blok);
      case 'richtext':
        return _renderRichTextComponent(context, provider, blok);
      default:
        return null; // Not a built-in component
    }
  }

  /// Built-in page component renderer
  Widget _renderPageComponent(BuildContext context, StoryblokProvider provider, StoryblokBlok blok) {
    final body = blok.content['body'] as List? ?? [];

    return SimpleStoryblokEditable(
      content: blok.toJson(),
      child: body.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.article_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your page content will appear here',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add components to the body field in Storyblok',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: body.map((item) {
                if (item is Map<String, dynamic>) {
                  return StoryblokComponent(
                    content: item,
                    componentKey: item['_uid'] ?? 'page-item',
                  );
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
    );
  }

  /// Built-in text component renderer
  Widget _renderTextComponent(BuildContext context, StoryblokProvider provider, StoryblokBlok blok) {
    final text = blok.content['text'] as String? ?? '';
    final textAlign = blok.content['text_align'] as String? ?? 'left';

    TextAlign alignment = TextAlign.left;
    switch (textAlign) {
      case 'center':
        alignment = TextAlign.center;
        break;
      case 'right':
        alignment = TextAlign.right;
        break;
      case 'justify':
        alignment = TextAlign.justify;
        break;
    }

    return SimpleStoryblokEditable(
      content: blok.toJson(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          textAlign: alignment,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  /// Built-in richtext component renderer (simplified)
  Widget _renderRichTextComponent(BuildContext context, StoryblokProvider provider, StoryblokBlok blok) {
    final richtext = blok.content['richtext'];
    String text = '';

    // Simple richtext parsing - you might want to implement proper richtext rendering
    if (richtext is Map) {
      text = _extractTextFromRichtext(richtext);
    } else if (richtext is String) {
      text = richtext;
    }

    return SimpleStoryblokEditable(
      content: blok.toJson(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  /// Extract plain text from richtext structure (simplified)
  String _extractTextFromRichtext(Map richtext) {
    if (richtext.containsKey('content')) {
      final content = richtext['content'] as List?;
      if (content != null) {
        return content.map((item) {
          if (item is Map && item.containsKey('content')) {
            return _extractTextFromRichtext(item);
          } else if (item is Map && item.containsKey('text')) {
            return item['text'] as String;
          }
          return '';
        }).join(' ');
      }
    }
    return richtext['text'] as String? ?? '';
  }

  Widget _buildMissingComponentWidget(String componentName) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(4),
        color: Colors.red.withOpacity(0.1),
      ),
      child: Text(
        'Component "$componentName" not found',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildErrorWidget(String componentName, String error) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(4),
        color: Colors.orange.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Error in component "$componentName"',
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: const TextStyle(color: Colors.orange, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Widget that renders a complete Storyblok story
class StoryblokViewStory extends StatelessWidget {
  final String? storySlug;

  const StoryblokViewStory({super.key, this.storySlug});

  @override
  Widget build(BuildContext context) {
    final provider = StoryblokProvider.require(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading story',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final content = provider.currentContent?.content;
    if (content == null) {
      return const Center(child: Text('No content available'));
    }

    return StoryblokComponent(content: content);
  }
}

/// Widget that renders a specific field from Storyblok content
class StoryblokField extends StatelessWidget {
  final String fieldName;
  final Map<String, dynamic>? content;

  const StoryblokField({super.key, required this.fieldName, this.content});

  @override
  Widget build(BuildContext context) {
    final provider = StoryblokProvider.require(context);
    final sourceContent = content ?? provider.currentContent?.content;

    if (sourceContent == null || !sourceContent.containsKey(fieldName)) {
      return const SizedBox.shrink();
    }

    final fieldContent = sourceContent[fieldName];
    return StoryblokComponent(content: fieldContent, componentKey: fieldName);
  }
}