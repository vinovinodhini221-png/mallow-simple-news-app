
class ArticleModel {
  final int id;
  final String title;
  final String url;
  final String? imageUrl;
  final String newsSite;
  final String? summary;
  final DateTime? publishedAt;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.url,
    this.imageUrl,
    required this.newsSite,
    this.summary,
    this.publishedAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? 'Untitled',
      url: json['url'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      newsSite: json['news_site'] as String? ?? 'Unknown source',
      summary: json['summary'] as String?,
      publishedAt: DateTime.tryParse(
        json['published_at']?.toString() ?? '',
      ),
    );
  }
}
