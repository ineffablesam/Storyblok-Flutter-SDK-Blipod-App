# Storyblok Flutter SDK

A comprehensive Flutter package for integrating with Storyblok CMS, supporting both mobile and web platforms with visual editor integration for Flutter Web.

## Features

- ✅ **Cross-platform**: Works on iOS, Android, and Web
- ✅ **Visual Editor**: Full integration with Storyblok's visual editor on Flutter Web
- ✅ **Component System**: Register and render custom Flutter widgets for Storyblok components
- ✅ **Real-time Updates**: Live preview updates in the visual editor
- ✅ **Type Safety**: Full Dart type safety with comprehensive models
- ✅ **Error Handling**: Graceful error handling with customizable error widgets
- ✅ **Debug Support**: Comprehensive logging and debug information

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  storyblok_flutter: ^1.0.0
  http: ^1.1.0  # Required for API calls
```

For web support, also add:

```yaml
dependencies:
  flutter_web_plugins: any
```

## Quick Start

### 1. Basic Setup

Wrap your app with `StoryblokProviderWrapper`:

```dart
import 'package:flutter/material.dart';
import 'package:storyblok_flutter/storyblok_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StoryblokProviderWrapper(
        config: const StoryblokConfig(
          token: 'your-preview-token-here',
          debug: true,
        ),
        storySlug: 'home',
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Storyblok App')),
      body: StoryblokStory(), // This will render your story content
    );
  }
}
```

### 2. Register Components

Create component builders for your Storyblok components:

```dart
StoryblokProviderWrapper(
  config: const StoryblokConfig(token: 'your-token'),
  storySlug: 'home',
  components: {
    'hero': (context, blok, props) {
      return Container(
        height: 300,
        color: Colors.blue,
        child: Center(
          child: Text(
            props['title'] ?? 'Hero Title',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      );
    },
    'text': (context, blok, props) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Text(props['content'] ?? ''),
      );
    },
  },
  child: HomePage(),
)
```

### 3. Handle Editable Content (Web Only)

For visual editor support, wrap your components with `SimpleStoryblokEditable`:

```dart
Widget buildHeroComponent(BuildContext context, StoryblokBlok blok, Map<String, dynamic> props) {
  return SimpleStoryblokEditable(
    content: blok.toJson(),
    child: Container(
      height: 300,
      color: Colors.blue,
      child: Center(
        child: Text(
          props['title'] ?? 'Hero Title',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    ),
  );
}
```

## Configuration

### StoryblokConfig Options

```dart
const StoryblokConfig(
  token: 'your-preview-token',        // Required: Your Storyblok preview token
  version: StoryblokVersion.draft,    // Optional: draft (default) or published
  region: StoryblokRegion.eu,         // Optional: eu (default), us, ap, ca
  debug: true,                        // Optional: Enable debug logging
)
```

### Regions

The SDK supports all Storyblok regions:

- `StoryblokRegion.eu` - Europe (default)
- `StoryblokRegion.us` - United States
- `StoryblokRegion.ap` - Asia-Pacific
- `StoryblokRegion.ca` - Canada

## Advanced Usage

### Custom Widgets

#### Display Specific Fields

```dart
StoryblokField(
  fieldName: 'hero_section',
  // Optional: pass custom content instead of using provider's content
  content: customContent,
)
```

#### Multiple Stories

```dart
class ProductPage extends StatefulWidget {
  final String productSlug;
  
  const ProductPage({required this.productSlug});
  
  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  StoryblokStory? story;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    loadStory();
  }
  
  Future<void> loadStory() async {
    try {
      final sdk = StoryblokSDK.instance;
      final loadedStory = await sdk.fetchStory(widget.productSlug);
      setState(() {
        story = loadedStory;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CircularProgressIndicator();
    }
    
    return StoryblokComponent(
      content: story?.content ?? {},
    );
  }
}
```

### Error Handling

```dart
StoryblokProviderWrapper(
  config: config,
  storySlug: 'home',
  onError: (error) {
    // Handle errors globally
    print('Storyblok error: $error');
    // You could show a snackbar, log to analytics, etc.
  },
  child: HomePage(),
)
```

### Event Handling

Listen to Storyblok editor events:

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  StreamSubscription<StoryblokEvent>? _subscription;
  
  @override
  void initState() {
    super.initState();
    
    // Listen to all events
    _subscription = StoryblokSDK.instance.eventStream.listen((event) {
      print('Storyblok event: ${event.type}');
      
      if (event.type == StoryblokEventType.published) {
        // Handle publish events
        setState(() {
          // Refresh UI
        });
      }
    });
    
    // Or listen to specific events
    StoryblokSDK.instance
        .listenToEvent(StoryblokEventType.input)
        .listen((event) {
      // Handle input events specifically
    });
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

## Web Integration

### Visual Editor Setup

For Flutter Web visual editor integration:

1. **Build your Flutter web app**:
   ```bash
   flutter build web
   ```

2. **Host your Flutter web app** on a domain accessible to Storyblok

3. **Configure Storyblok Visual Editor**:
    - Go to your Storyblok space settings
    - Navigate to "Visual Editor"
    - Set your preview URL to your Flutter web app domain
    - Add any necessary headers or authentication

4. **Test the Integration**:
    - Open a story in Storyblok's visual editor
    - Your Flutter web app should load in the preview pane
    - Changes should appear in real-time as you edit

### Environment Detection

The SDK automatically detects when running in the Storyblok editor:

```dart
final provider = StoryblokProvider.of(context);
if (provider.sdk.isInEditor) {
  // Show editor-specific UI
} else {
  // Show production UI
}
```

## API Reference

### Core Classes

#### StoryblokSDK
Main SDK class providing API access and component management.

```dart
// Get singleton instance
final sdk = StoryblokSDK.instance;

// Initialize
await sdk.initialize(config);

// Fetch single story
final story = await sdk.fetchStory('home');

// Fetch multiple stories
final stories = await sdk.fetchStories(startsWith: 'blog/');

// Register components
sdk.registerComponent('hero', heroBuilder);
sdk.registerComponents({'text': textBuilder, 'image': imageBuilder});
```

#### StoryblokProvider
Inherited widget providing Storyblok data to the widget tree.

```dart
final provider = StoryblokProvider.require(context);

// Access current story data
final content = provider.currentContent;
final isDraft = provider.sdk.isInEditor;

// Check loading state
if (provider.isLoading) {
  return CircularProgressIndicator();
}

// Handle errors
if (provider.error != null) {
  return Text('Error: ${provider.error}');
}
```

### Widget Reference

#### StoryblokStory
Renders a complete Storyblok story.

#### StoryblokComponent
Renders individual Storyblok components or content blocks.

#### StoryblokField
Renders a specific field from the current story.

#### SimpleStoryblokEditable
Wraps content to enable visual editing (web only).

## Troubleshooting

### Common Issues

**1. "Component not found" errors**
- Ensure you've registered all components used in your Storyblok content
- Check component names match exactly between Storyblok and your Flutter code
- Enable debug mode to see detailed logs

**2. Visual editor not loading**
- Check CORS settings on your web server
- Verify your Flutter web app is accessible from the Storyblok editor domain
- Check browser console for JavaScript errors

**3. Content not updating in editor**
- Ensure you're using draft version in editor mode
- Check that your components are properly wrapped with editable widgets
- Verify event listeners are properly set up

### Debug Mode

Enable comprehensive logging:

```dart
const StoryblokConfig(
  token: 'your-token',
  debug: true, // Enables detailed logging
)
```

This will log:
- API requests and responses
- Component registration
- Editor events
- Error details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and feature requests, please use the [GitHub issue tracker](https://github.com/your-username/storyblok_flutter/issues).

For Storyblok-specific questions, consult the [official Storyblok documentation](https://www.storyblok.com/docs).


openssl req -x509 -newkey rsa:2048 -nodes -keyout localhost-key.pem -out localhost.pem -days 365


flutter run -d chrome --web-ssl-cert-file localhost.pem --web-ssl-key-file localhost-key.pem
