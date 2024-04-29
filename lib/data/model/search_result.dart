class SearchResult {
  final Query? query;

  const SearchResult({required this.query});

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
        query: json['query'] == null ? null : Query.fromJson(json['query']));
  }
}

class Query {
  final List<Page?>? pages;
  const Query({required this.pages});
  factory Query.fromJson(Map<String, dynamic> json) {
    return Query(
      pages: json['pages']!=null ? (json['pages'] as List<dynamic>?)
          ?.map((page) => Page.fromJson(page))
          .toList() ?? []: []
    );

  }
}

class Page {
  final int pageId;
  final String title;
  final Thumbnail? thumbnail;
  final Terms? terms;
  final String? extract;

  const Page({required this.pageId, required this.title, this.thumbnail, this.terms, this.extract});
  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      pageId: json['pageid'],
      title: json['title'],
      thumbnail: json.containsKey('thumbnail') ? Thumbnail.fromJson(json['thumbnail']) : null,
      terms: json.containsKey('terms') ? Terms.fromJson(json['terms']) : null,
      extract: json['extract']
    );
  }

}

class Thumbnail {
  final String source;
  final int width;
  final int height;

  Thumbnail({
    required this.source,
    required this.width,
    required this.height,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      source: json['source'],
      width: json['width'],
      height: json['height'],
    );
  }
}

class Terms {
  final List<String> description;

  Terms({
    required this.description,
  });

  factory Terms.fromJson(Map<String, dynamic> json) {
    return Terms(
      description: List<String>.from(json['description'].map((desc) => desc)),
    );
  }
}