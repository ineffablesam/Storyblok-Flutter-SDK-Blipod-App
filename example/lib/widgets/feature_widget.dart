// lib/widgets/feature_widget.dart
import 'package:flutter/material.dart';
import 'package:storyblok_flutter/storyblok_flutter.dart';

class FeatureWidget extends StatelessWidget {
  final StoryblokBlok blok;
  final Map<String, dynamic> props;

  const FeatureWidget({super.key, required this.blok, required this.props});

  static Widget builder(
    BuildContext context,
    StoryblokBlok blok,
    Map<String, dynamic> props,
  ) {
    return FeatureWidget(blok: blok, props: props);
  }

  @override
  Widget build(BuildContext context) {
    final name = props['name'] as String? ?? 'Feature';

    return SimpleStoryblokEditable(
      content: blok.toJson(),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
