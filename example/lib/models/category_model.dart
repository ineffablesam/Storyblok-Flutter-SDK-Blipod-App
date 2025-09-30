// To parse this JSON data, do
//
//     final category = categoryFromJson(jsonString);

import 'dart:convert';

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));

String categoryToJson(Category data) => json.encode(data.toJson());
Category categoryFromDynamic(dynamic data) {
  if (data == null) {
    return Category(categories: []);
  }

  if (data is String) {
    // case: raw JSON string
    return Category.fromJson(json.decode(data));
  }

  if (data is Map<String, dynamic>) {
    // case: already a decoded map
    return Category.fromJson(data);
  }

  if (data is List) {
    // case: it's already a list of category elements
    return Category(
      categories: data
          .map((e) => CategoryElement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  throw ArgumentError(
    "Unsupported type for categoryFromDynamic: ${data.runtimeType}",
  );
}

List<CategoryElement> subCategoriesFromDynamic(dynamic data) {
  if (data == null) return [];

  if (data is String) {
    final decoded = json.decode(data);
    if (decoded is List) {
      return decoded
          .map((e) => CategoryElement.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ArgumentError("Invalid JSON string for subCategories");
  }

  if (data is List) {
    return data
        .map((e) => CategoryElement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  throw ArgumentError(
    "Unsupported type for subCategoriesFromDynamic: ${data.runtimeType}",
  );
}

class Category {
  List<CategoryElement>? categories;

  Category({this.categories});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    categories: json["categories"] == null
        ? []
        : List<CategoryElement>.from(
            json["categories"]!.map((x) => CategoryElement.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "categories": categories == null
        ? []
        : List<dynamic>.from(categories!.map((x) => x.toJson())),
  };
}

class CategoryElement {
  String? uid;
  String? name;
  String? slug;
  CategoryColor? color;
  List<Article>? article;
  String? component;
  String? thumbnail;
  List<CategoryElement>? subCategory;

  CategoryElement({
    this.uid,
    this.name,
    this.slug,
    this.color,
    this.article,
    this.component,
    this.thumbnail,
    this.subCategory,
  });

  factory CategoryElement.fromJson(
    Map<String, dynamic> json,
  ) => CategoryElement(
    uid: json["_uid"],
    name: json["name"],
    slug: json["slug"],
    color: json["color"] == null ? null : CategoryColor.fromJson(json["color"]),
    article: json["article"] == null
        ? []
        : List<Article>.from(json["article"]!.map((x) => Article.fromJson(x))),
    component: json["component"],
    thumbnail: json["thumbnail"],
    subCategory: json["sub_category"] == null
        ? []
        : List<CategoryElement>.from(
            json["sub_category"]!.map((x) => CategoryElement.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "_uid": uid,
    "name": name,
    "slug": slug,
    "color": color?.toJson(),
    "article": article == null
        ? []
        : List<dynamic>.from(article!.map((x) => x.toJson())),
    "component": component,
    "thumbnail": thumbnail,
    "sub_category": subCategory == null
        ? []
        : List<dynamic>.from(subCategory!.map((x) => x.toJson())),
  };
}

class Article {
  String? uid;
  Link? link;
  String? name;
  bool? enabled;
  String? subtitle;
  String? component;
  String? thumbnail;

  Article({
    this.uid,
    this.link,
    this.name,
    this.enabled,
    this.subtitle,
    this.component,
    this.thumbnail,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    uid: json["_uid"],
    link: json["link"] == null ? null : Link.fromJson(json["link"]),
    name: json["name"],
    enabled: json["enabled"],
    subtitle: json["subtitle"],
    component: json["component"],
    thumbnail: json["thumbnail"],
  );

  Map<String, dynamic> toJson() => {
    "_uid": uid,
    "link": link?.toJson(),
    "name": name,
    "enabled": enabled,
    "subtitle": subtitle,
    "component": component,
    "thumbnail": thumbnail,
  };
}

class Link {
  String? id;
  String? url;
  String? linktype;
  String? fieldtype;
  String? cachedUrl;

  Link({this.id, this.url, this.linktype, this.fieldtype, this.cachedUrl});

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    id: json["id"],
    url: json["url"],
    linktype: json["linktype"],
    fieldtype: json["fieldtype"],
    cachedUrl: json["cached_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "linktype": linktype,
    "fieldtype": fieldtype,
    "cached_url": cachedUrl,
  };
}

class CategoryColor {
  String? uid;
  String? color;
  String? plugin;

  CategoryColor({this.uid, this.color, this.plugin});

  factory CategoryColor.fromJson(Map<String, dynamic> json) => CategoryColor(
    uid: json["_uid"],
    color: json["color"],
    plugin: json["plugin"],
  );

  Map<String, dynamic> toJson() => {
    "_uid": uid,
    "color": color,
    "plugin": plugin,
  };
}
