import 'package:flutter_test/flutter_test.dart';
import 'package:mallow_news_app/core/network/api_client.dart';
import 'package:mallow_news_app/data/repositories/article_repository.dart';

class FakeApiClient extends ApiClient {
  Map<String, dynamic> responseToReturn = {};

  @override
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return responseToReturn;
  }
}

void main() {
  group('ArticleRepository', () {
    late FakeApiClient fakeApiClient;
    late ArticleRepository repository;

    setUp(() {
      fakeApiClient = FakeApiClient();
      repository = ArticleRepository(fakeApiClient);
    });

    test('getArticles parses and returns ArticlePage', () async {
      fakeApiClient.responseToReturn = {
        'count': 1,
        'next': 'https://api.spaceflightnewsapi.net/v4/articles/?limit=10&offset=10',
        'previous': null,
        'results': [
          {
            'id': 1,
            'title': 'Test Article',
            'url': 'https://example.com/1',
            'image_url': 'https://example.com/1.jpg',
            'news_site': 'NASA',
            'summary': 'Summary test',
            'published_at': '2026-11-18T00:00:00Z',
          }
        ],
      };

      final page = await repository.getArticles();

      expect(page.totalCount, 1);
      expect(page.hasNextPage, isTrue);
      expect(page.articles.length, 1);
      expect(page.articles.first.id, 1);
      expect(page.articles.first.title, 'Test Article');
    });

    test('getArticleDetails parses and returns ArticleModel', () async {
      fakeApiClient.responseToReturn = {
        'id': 42,
        'title': 'Specific Article',
        'url': 'https://example.com/42',
        'image_url': null,
        'news_site': 'SpaceNews',
        'summary': 'Details summary',
        'published_at': '2026-11-18T00:00:00Z',
      };

      final article = await repository.getArticleDetails(42);

      expect(article.id, 42);
      expect(article.title, 'Specific Article');
      expect(article.newsSite, 'SpaceNews');
    });

    test('getNewsSites parses and returns list of news sites', () async {
      fakeApiClient.responseToReturn = {
        'version': '4.37.1',
        'news_sites': ['NASA', 'SpaceNews', 'Spaceflight Now'],
      };

      final sites = await repository.getNewsSites();

      expect(sites, ['NASA', 'SpaceNews', 'Spaceflight Now']);
    });
  });
}
