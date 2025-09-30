# Storyblok Flutter SDK

A powerful Flutter SDK for integrating Storyblok CMS with full support for visual editing, component rendering, and cross-platform development.

## Features

- 🚀 **Cross-Platform**: Works on Web, iOS, Android, and Desktop
- ✨ **Visual Editor**: Full Storyblok Visual Editor integration on web
- 🧩 **Component System**: Flexible component registration and rendering
- 🌍 **Multi-Region**: Support for EU, US, AP, and CA regions
- 📱 **Responsive**: Automatically handles different screen sizes
- 🔥 **Hot Reload**: Real-time content updates in development
- 📊 **TypeSafe**: Strong typing for Storyblok content structures

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  your_package_name: ^1.0.0
  go_router: ^12.0.0  # For routing
  http: ^1.1.0        # For API calls
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Basic Setup

```dart
import 'package:flutter/material.dart';
import 'package:your_package_name/storyblok_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StoryblokProviderWrapper(
        config: const StoryblokConfig(
          token: 'YOUR_STORYBLOK_TOKEN',
          version: StoryblokVersion.published,
          debug: true,
        ),
        storySlug: 'home',
        components: {
          'hero': (context, blok, props) => HeroComponent(blok: blok),
          'text': (context, blok, props) => TextComponent(blok: blok),
        },
        child: Scaffold(
          body: StoryblokStory(),
        ),
      ),
    );
  }
}
```

### 2. With GoRouter Integration

```dart
import 'package:go_router/go_router.dart';

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/page/:slug',
            builder: (context, state) {
              final slug = state.pathParameters['slug']!;
              return DynamicStoryblokPage(slug: slug);
            },
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
```

## Configuration

### StoryblokConfig Options

```dart
const StoryblokConfig(
  token: 'YOUR_STORYBLOK_TOKEN',     // Required: Your Storyblok access token
  version: StoryblokVersion.draft,    // draft | published
  region: StoryblokRegion.eu,         // eu | us | ap | ca
  debug: true,                        // Enable debug logging
)
```

### Environment Variables

Create a `.env` file in your project root:

```env
STORYBLOK_TOKEN=your_storyblok_token_here
STORYBLOK_PREVIEW_TOKEN=your_preview_token_here
```

## Creating Custom Components

### Basic Component

```dart
class HeroComponent extends StatelessWidget {
  final StoryblokBlok blok;

  const HeroComponent({Key? key, required this.blok}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = blok.content['title'] as String? ?? '';
    final subtitle = blok.content['subtitle'] as String? ?? '';
    
    return SimpleStoryblokEditable(
      content: blok.toJson(),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 16),
            Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
```

### Advanced Component with Nested Content

```dart
class GridComponent extends StatelessWidget {
  final StoryblokBlok blok;

  const GridComponent({Key? key, required this.blok}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columns = blok.content['columns'] as int? ?? 2;
    final items = blok.content['items'] as List? ?? [];

    return SimpleStoryblokEditable(
      content: blok.toJson(),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return StoryblokComponent(
            content: items[index],
            componentKey: '${blok.uid}-item-$index',
          );
        },
      ),
    );
  }
}
```

## Component Registration

### Single Component

```dart
StoryblokSDK.instance.registerComponent(
  'hero',
  (context, blok, props) => HeroComponent(blok: blok),
);
```

### Multiple Components

```dart
StoryblokSDK.instance.registerComponents({
  'hero': (context, blok, props) => HeroComponent(blok: blok),
  'text_block': (context, blok, props) => TextBlockComponent(blok: blok),
  'image': (context, blok, props) => ImageComponent(blok: blok),
  'button': (context, blok, props) => ButtonComponent(blok: blok),
});
```

### In Provider Wrapper

```dart
StoryblokProviderWrapper(
  config: storyblokConfig,
  storySlug: 'home',
  components: {
    'hero': (context, blok, props) => HeroComponent(blok: blok),
    'text_block': (context, blok, props) => TextBlockComponent(blok: blok),
  },
  child: YourWidget(),
)
```

## Visual Editor Integration

The SDK automatically handles Visual Editor integration when running on web platforms inside the Storyblok editor.

### Making Components Editable

Wrap your components with `SimpleStoryblokEditable`:

```dart
return SimpleStoryblokEditable(
  content: blok.toJson(),
  child: YourWidgetContent(),
);
```

### Event Handling

Listen to Storyblok editor events:

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription<StoryblokEvent> _eventSubscription;

  @override
  void initState() {
    super.initState();
    
    // Listen to all events
    _eventSubscription = StoryblokSDK.instance.eventStream.listen((event) {
      print('Received event: ${event.type}');
      // Handle the event
    });
    
    // Or listen to specific events
    StoryblokSDK.instance
        .listenToEvent(StoryblokEventType.input)
        .listen((event) {
      // Handle content changes in real-time
      if (mounted) {
        setState(() {
          // Update your UI
        });
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YourWidget();
  }
}
```

## API Methods

### Fetch Single Story

```dart
try {
  final story = await StoryblokSDK.instance.fetchStory(
    'home',
    version: StoryblokVersion.draft,
  );
  print('Story: ${story.name}');
} catch (e) {
  print('Error: $e');
}
```

### Fetch Multiple Stories

```dart
try {
  final stories = await StoryblokSDK.instance.fetchStories(
    startsWith: 'blog/',
    perPage: 10,
    page: 1,
    sortBy: 'created_at:desc',
  );
  print('Found ${stories.length} stories');
} catch (e) {
  print('Error: $e');
}
```

### Advanced Query Options

```dart
final stories = await StoryblokSDK.instance.fetchStories(
  startsWith: 'blog/',
  excludingSlugs: 'blog/draft-post,blog/archived',
  filterQuery: {
    'category': {'in': 'tech,design'},
    'published': {'is': 'true'},
  },
  sortBy: 'first_published_at:desc',
  perPage: 20,
  resolvingLinks: 'url',
  resolvingRelations: 'author',
);
```

## Widgets Reference

### StoryblokProviderWrapper

Main wrapper that initializes the SDK and provides Storyblok context.

```dart
StoryblokProviderWrapper(
  config: StoryblokConfig(...),
  storySlug: 'home',
  components: {...},
  onError: (error) => print('Error: $error'),
  child: YourWidget(),
)
```

### StoryblokStory

Renders a complete Storyblok story.

```dart
StoryblokStory(
  storySlug: 'custom-slug', // Optional: overrides provider slug
)
```

### StoryblokComponent

Renders individual Storyblok components.

```dart
StoryblokComponent(
  content: componentData,
  componentKey: 'unique-key', // Optional
)
```

### StoryblokField

Renders a specific field from Storyblok content.

```dart
StoryblokField(
  fieldName: 'body',
  content: storyContent, // Optional: uses provider content if null
)
```

### SimpleStoryblokEditable

Makes content editable in the Visual Editor.

```dart
SimpleStoryblokEditable(
  content: blok.toJson(),
  child: YourWidget(),
)
```

## Built-in Components

The SDK includes several built-in components:

- **page**: Basic page layout with body content
- **text**: Simple text rendering with alignment options
- **richtext**: Rich text content rendering (basic)

These work automatically without registration.

## Platform Considerations

### Web Platform

- Full Visual Editor integration
- Real-time content updates
- Bridge communication with Storyblok editor
- URL parameter cleaning

### Mobile Platforms (iOS/Android)

- API-only integration (no Visual Editor)
- Optimized for production content delivery
- Same component system and rendering

### Desktop Platforms

- Similar to mobile platforms
- No Visual Editor integration
- Full API functionality

## Best Practices

### 1. Component Organization

```dart
// lib/components/storyblok/index.dart
export 'hero_component.dart';
export 'text_block_component.dart';
export 'image_component.dart';

// lib/utils/storyblok_components.dart
Map<String, StoryblokComponentBuilder> getStoryblokComponents() {
  return {
    'hero': (context, blok, props) => HeroComponent(blok: blok),
    'text_block': (context, blok, props) => TextBlockComponent(blok: blok),
    'image': (context, blok, props) => ImageComponent(blok: blok),
  };
}
```

### 2. Error Handling

```dart
StoryblokProviderWrapper(
  config: config,
  storySlug: slug,
  onError: (error) {
    // Log to crash reporting service
    FirebaseCrashlytics.instance.recordError(error, null);
    
    // Show user-friendly message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load content')),
    );
  },
  child: child,
)
```

### 3. Performance Optimization

```dart
// Use keys for better Flutter performance
StoryblokComponent(
  content: item,
  componentKey: item['_uid'] ?? 'fallback-${index}',
)

// Implement lazy loading for images
class OptimizedImageComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return CircularProgressIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.error);
      },
    );
  }
}
```

### 4. State Management

```dart
// With Provider
class StoryblokProvider extends ChangeNotifier {
  StoryblokStory? _currentStory;
  
  void updateStory(StoryblokStory story) {
    _currentStory = story;
    notifyListeners();
  }
}

// With Riverpod
final storyProvider = StateNotifierProvider<StoryNotifier, StoryblokStory?>((ref) {
  return StoryNotifier();
});
```

## Environment Setup

### Development

```dart
const StoryblokConfig(
  token: 'YOUR_PREVIEW_TOKEN',
  version: StoryblokVersion.draft,
  debug: true,
)
```

### Production

```dart
const StoryblokConfig(
  token: 'YOUR_PUBLIC_TOKEN',
  version: StoryblokVersion.published,
  debug: false,
)
```

### Environment Variables

```bash
# .env
STORYBLOK_TOKEN=your_token_here
STORYBLOK_PREVIEW_TOKEN=your_preview_token_here

# Different environments
STORYBLOK_TOKEN_DEV=dev_token
STORYBLOK_TOKEN_STAGING=staging_token
STORYBLOK_TOKEN_PROD=production_token
```

## Troubleshooting

### Common Issues

1. **Component not found**: Ensure component is registered before use
2. **Visual Editor not working**: Check if running on web platform and inside Storyblok editor
3. **API errors**: Verify token and story slug are correct
4. **Build errors on mobile**: Ensure platform-specific imports are set up correctly

### Debug Mode

Enable debug mode to see detailed logging:

```dart
const StoryblokConfig(
  debug: true, // Enables detailed console logging
)
```

### Error Widget Customization

```dart
// Override default error widgets in your components
Widget _buildErrorWidget(String componentName, String error) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.red),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Icon(Icons.error, color: Colors.red),
        Text('Error in $componentName'),
        Text(error, style: TextStyle(fontSize: 12)),
      ],
    ),
  );
}
```

## Migration Guide

### From Other Storyblok SDKs

If you're migrating from other Flutter Storyblok solutions:

1. Replace your existing Storyblok dependencies
2. Update component registration syntax
3. Wrap your app with `StoryblokProviderWrapper`
4. Update component builders to use new `StoryblokBlok` structure

### Breaking Changes

- Component builders now receive `StoryblokBlok` instead of raw JSON
- Event handling uses streams instead of callbacks
- Configuration uses `StoryblokConfig` class

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- [Documentation](https://github.com/yourusername/your_package_name/wiki)
- [Issues](https://github.com/yourusername/your_package_name/issues)
- [Discussions](https://github.com/yourusername/your_package_name/discussions)
- [Storyblok Documentation](https://www.storyblok.com/docs)

## Changelog

### 1.0.0
- Initial release
- Cross-platform support
- Visual Editor integration
- Component system
- GoRouter integration
- Built-in components