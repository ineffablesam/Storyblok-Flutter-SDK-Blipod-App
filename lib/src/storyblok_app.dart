// lib/src/storyblok_app.dart
import 'package:flutter/material.dart';
import 'storyblok_config.dart';
import 'storyblok_sdk.dart';
import 'types.dart';

/// Global Storyblok app wrapper - use this once at your app root
class StoryblokApp extends StatefulWidget {
  final Widget child;
  final StoryblokConfig config;
  final Map<String, StoryblokComponentBuilder>? components;
  final void Function(String error)? onError;

  const StoryblokApp({
    super.key,
    required this.child,
    required this.config,
    this.components,
    this.onError,
  });

  @override
  State<StoryblokApp> createState() => _StoryblokAppState();
}

class _StoryblokAppState extends State<StoryblokApp> {
  late StoryblokSDK _sdk;
  bool _isInitialized = false;
  String? _error;

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

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isInitialized = true; // Still mark as initialized to show error
      });
      widget.onError?.call(e.toString());
    }
  }

  @override
  void dispose() {
    // Don't dispose SDK here as it's global
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text('Failed to initialize Storyblok'),
                const SizedBox(height: 8),
                Text(_error!, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    return GlobalStoryblokProvider(
      sdk: _sdk,
      config: widget.config,
      child: widget.child,
    );
  }
}

/// Global provider that makes SDK available throughout the app
class GlobalStoryblokProvider extends InheritedWidget {
  final StoryblokSDK sdk;
  final StoryblokConfig config;

  const GlobalStoryblokProvider({
    super.key,
    required this.sdk,
    required this.config,
    required super.child,
  });

  @override
  bool updateShouldNotify(GlobalStoryblokProvider oldWidget) {
    return sdk != oldWidget.sdk || config != oldWidget.config;
  }

  static GlobalStoryblokProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GlobalStoryblokProvider>();
  }

  static GlobalStoryblokProvider require(BuildContext context) {
    final provider = of(context);
    if (provider == null) {
      throw FlutterError(
        'GlobalStoryblokProvider.require was called with a context that does not contain a GlobalStoryblokProvider.\n'
        'Ensure that StoryblokApp is an ancestor of the widget.',
      );
    }
    return provider;
  }
}