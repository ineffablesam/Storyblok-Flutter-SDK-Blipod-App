// lib/src/storyblok_config.dart
class StoryblokConfig {
  final String token;
  final StoryblokVersion version;
  final StoryblokRegion region;
  final bool debug;

  const StoryblokConfig({
    required this.token,
    this.version = StoryblokVersion.draft,
    this.region = StoryblokRegion.eu,
    this.debug = false,
  });

  StoryblokConfig copyWith({
    String? token,
    StoryblokVersion? version,
    StoryblokRegion? region,
    bool? debug,
  }) {
    return StoryblokConfig(
      token: token ?? this.token,
      version: version ?? this.version,
      region: region ?? this.region,
      debug: debug ?? this.debug,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'version': version.name,
      'region': region.name,
      'debug': debug,
    };
  }

  String get apiBaseUrl {
    switch (region) {
      case StoryblokRegion.us:
        return 'https://api-us.storyblok.com/v2';
      case StoryblokRegion.ap:
        return 'https://api-ap.storyblok.com/v2';
      case StoryblokRegion.ca:
        return 'https://api-ca.storyblok.com/v2';
      case StoryblokRegion.eu:
      default:
        return 'https://api.storyblok.com/v2';
    }
  }
}

enum StoryblokVersion {
  draft,
  published;

  String get name => toString().split('.').last;
}

enum StoryblokRegion {
  eu,
  us,
  ap,
  ca;

  String get name => toString().split('.').last;
}
