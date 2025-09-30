// lib/src/component_registry.dart
import 'types.dart';

/// Registry for Storyblok component builders
class ComponentRegistry {
  static ComponentRegistry? _instance;
  static ComponentRegistry get instance => _instance ??= ComponentRegistry._();

  ComponentRegistry._();

  final Map<String, StoryblokComponentBuilder> _components = {};

  /// Register a component builder
  void register(String name, StoryblokComponentBuilder builder) {
    _components[name] = builder;
  }

  /// Register multiple component builders
  void registerAll(Map<String, StoryblokComponentBuilder> components) {
    _components.addAll(components);
  }

  /// Get a component builder
  StoryblokComponentBuilder? get(String name) {
    return _components[name];
  }

  /// Check if a component is registered
  bool has(String name) {
    return _components.containsKey(name);
  }

  /// Get all registered component names
  List<String> get componentNames => _components.keys.toList();

  /// Get component count
  int get count => _components.length;

  /// Clear all components
  void clear() {
    _components.clear();
  }

  /// Remove a specific component
  void remove(String name) {
    _components.remove(name);
  }
}
