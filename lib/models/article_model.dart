class Article {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String source;
  final DateTime publishedAt;

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.source,
    required this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    String sourceName;

    // Handle both String and Map source formats
    if (json['source'] is Map<String, dynamic>) {
      sourceName = json['source']['name'] ?? '';
    } else if (json['source'] is String) {
      sourceName = json['source'];
    } else {
      sourceName = '';
    }

    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      source: sourceName,
      publishedAt: DateTime.parse(json['publishedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'url': url,
    'urlToImage': urlToImage,
    'source': source, // stored as simple string
    'publishedAt': publishedAt.toIso8601String(),
  };
}
