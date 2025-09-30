// lib/src/types.dart
import 'package:flutter/widgets.dart';

/// Story data structure from Storyblok API
class StoryblokStory {
  final int id;
  final String uuid;
  final String name;
  final String slug;
  final String fullSlug;
  final Map<String, dynamic> content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final bool isStartpage;
  final int? parentId;
  final Map<String, dynamic>? metaData;
  final String groupId;
  final DateTime? firstPublishedAt;
  final int? releaseId;
  final String lang;
  final String? path;
  final List<dynamic> alternates;
  final String? defaultFullSlug;
  final List<dynamic>? translatedSlugs;
  final String? sortByDate; // new: API sends this but can be null

  StoryblokStory({
    required this.id,
    required this.uuid,
    required this.name,
    required this.slug,
    required this.fullSlug,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    required this.isStartpage,
    this.parentId,
    this.metaData,
    required this.groupId,
    this.firstPublishedAt,
    this.releaseId,
    required this.lang,
    this.path,
    required this.alternates,
    this.defaultFullSlug,
    this.translatedSlugs,
    this.sortByDate,
  });

  factory StoryblokStory.fromJson(Map<String, dynamic> json) {
    return StoryblokStory(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      fullSlug: json['full_slug'] as String,
      content: (json['content'] ?? {}) as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      isStartpage: json['is_startpage'] ?? false,
      parentId: json['parent_id'] as int?,
      metaData: json['meta_data'] as Map<String, dynamic>?,
      groupId: json['group_id'] as String,
      firstPublishedAt: json['first_published_at'] != null
          ? DateTime.parse(json['first_published_at'] as String)
          : null,
      releaseId: json['release_id'] as int?,
      lang: json['lang'] as String,
      path: json['path'] as String?,
      alternates: json['alternates'] ?? [],
      defaultFullSlug: json['default_full_slug'] as String?,
      translatedSlugs: json['translated_slugs'] ?? [],
      sortByDate: json['sort_by_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'slug': slug,
      'full_slug': fullSlug,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'is_startpage': isStartpage,
      'parent_id': parentId,
      'meta_data': metaData,
      'group_id': groupId,
      'first_published_at': firstPublishedAt?.toIso8601String(),
      'release_id': releaseId,
      'lang': lang,
      'path': path,
      'alternates': alternates,
      'default_full_slug': defaultFullSlug,
      'translated_slugs': translatedSlugs,
      'sort_by_date': sortByDate,
    };
  }
}

/// Storyblok event types for the visual editor
enum StoryblokEventType {
  input,
  change,
  published,
  unpublished,
  viewLiveVersion,
  enterEditmode,
  enterComponent,
  hoverComponent,
  highlightComponent,
  customEvent,
  pingBack,
  sessionReceived,
  editedBlok,
  deselectBlok,
  addedBlock,
  deletedBlock,
  movedBlock,
  duplicatedBlock;

  String get name => toString().split('.').last;
}

/// Event data from Storyblok editor
class StoryblokEvent {
  final StoryblokEventType type;
  final Map<String, dynamic> data;
  final StoryblokStory? story;

  StoryblokEvent({required this.type, required this.data, this.story});

  factory StoryblokEvent.fromJson(
    StoryblokEventType type,
    Map<String, dynamic> json,
  ) {
    return StoryblokEvent(
      type: type,
      data: json,
      story: json['story'] != null
          ? StoryblokStory.fromJson(json['story'])
          : null,
    );
  }
}

/// Blok (component) structure
class StoryblokBlok {
  final String uid;
  final String component;
  final String? editable;
  final Map<String, dynamic> content;

  StoryblokBlok({
    required this.uid,
    required this.component,
    this.editable,
    required this.content,
  });

  factory StoryblokBlok.fromJson(Map<String, dynamic> json) {
    return StoryblokBlok(
      uid: json['_uid'] ?? '',
      component: json['component'] ?? '',
      editable: json['_editable'] as String?,
      content: Map<String, dynamic>.from(json)
        ..remove('_uid')
        ..remove('component')
        ..remove('_editable'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_uid': uid,
      'component': component,
      if (editable != null) '_editable': editable,
      ...content,
    };
  }
}

/// Component builder function type
typedef StoryblokComponentBuilder =
    Widget Function(
      BuildContext context,
      StoryblokBlok blok,
      Map<String, dynamic> props,
    );

/// Callback for Storyblok events
typedef StoryblokEventCallback = void Function(StoryblokEvent event);
