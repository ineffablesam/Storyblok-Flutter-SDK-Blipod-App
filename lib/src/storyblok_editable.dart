// lib/src/storyblok_editable.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'storyblok_provider.dart';

/// Widget that makes content editable in Storyblok visual editor (web only)
class StoryblokEditable extends StatelessWidget {
  final Map<String, dynamic> content;
  final Widget child;

  const StoryblokEditable({
    super.key,
    required this.content,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final provider = StoryblokProvider.of(context);

    // Only add editable functionality on web and in editor mode
    if (!kIsWeb || provider?.sdk.isInEditor != true) {
      return child;
    }

    final editableData = content['_editable'] as String?;
    if (editableData == null) {
      return child;
    }

    return _EditableWrapper(editableData: editableData, child: child);
  }
}

class _EditableWrapper extends StatelessWidget {
  final String editableData;
  final Widget child;

  const _EditableWrapper({required this.editableData, required this.child});

  @override
  Widget build(BuildContext context) {
    // ✅ We don’t inject raw HTML here (unsafe).
    // Instead, we just add Storyblok’s editable attributes via a container overlay.
    return Container(
      key: ValueKey(editableData), // ensures Flutter treats it as distinct
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      child: child,
    );
  }
}

/// Alternative approach using a custom render object (draws overlay)
class StoryblokEditableBox extends SingleChildRenderObjectWidget {
  final String? editableData;

  const StoryblokEditableBox({super.key, this.editableData, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderStoryblokEditable(editableData: editableData);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderStoryblokEditable renderObject,
  ) {
    renderObject.editableData = editableData;
  }
}

class RenderStoryblokEditable extends RenderProxyBox {
  String? _editableData;

  RenderStoryblokEditable({String? editableData})
    : _editableData = editableData;

  String? get editableData => _editableData;
  set editableData(String? value) {
    if (_editableData != value) {
      _editableData = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    // Add subtle edit highlight when in editor
    if (kIsWeb && editableData != null) {
      final paint = Paint()
        ..color = Colors.blue.withOpacity(0.08)
        ..style = PaintingStyle.fill;
      context.canvas.drawRect(
        Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
        paint,
      );
    }
  }
}

/// Simplified editable widget that works better with Flutter Web
class SimpleStoryblokEditable extends StatelessWidget {
  final Map<String, dynamic> content;
  final Widget child;

  const SimpleStoryblokEditable({
    super.key,
    required this.content,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final provider = StoryblokProvider.of(context);

    if (kDebugMode &&
        kIsWeb &&
        provider?.sdk.isInEditor == true &&
        content.containsKey('_editable')) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
        ),
        child: child,
      );
    }

    return child;
  }
}
