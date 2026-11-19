import 'package:flutter_test/flutter_test.dart';
import 'package:mallow_news_app/data/models/article_model.dart';

void main() {
  group('ArticleModel', () {
    test('parses complete json correctly', () {
      final json = {
        'id': 101,
        'title': 'SpaceX Starship orbital test',
        'url': 'https://example.com/spacex-test',
        'image_url': 'https://example.com/image.jpg',
        'news_site': 'SpaceNews',
        'summary': 'SpaceX conducted a full orbital flight test.',
        'published_at': '2026-11-18T10:00:00Z',
      };

      final article = ArticleModel.fromJson(json);

      expect(article.id, 101);
      expect(article.title, 'SpaceX Starship orbital test');
      expect(article.url, 'https://example.com/spacex-test');
      expect(article.imageUrl, 'https://example.com/image.jpg');
      expect(article.newsSite, 'SpaceNews');
      expect(article.summary, 'SpaceX conducted a full orbital flight test.');
      expect(article.publishedAt, isNotNull);
      expect(article.publishedAt?.year, 2026);
    });

    test('handles missing or null fields gracefully', () {
      final json = <String, dynamic>{
        'id': 202,
      };

      final article = ArticleModel.fromJson(json);

      expect(article.id, 202);
      expect(article.title, 'Untitled');
      expect(article.url, '');
      expect(article.imageUrl, isNull);
      expect(article.newsSite, 'Unknown source');
      expect(article.summary, isNull);
      expect(article.publishedAt, isNull);
    });
  });
}
