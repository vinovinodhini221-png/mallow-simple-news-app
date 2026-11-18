import 'package:mallow_tech/core/constants/app_constants.dart';
import 'package:mallow_tech/core/errors/app_exception.dart';
import 'package:mallow_tech/core/network/api_client.dart';
import 'package:mallow_tech/data/models/article_model.dart';

class ArticlePage {
  final List<ArticleModel> articles;
  final int totalCount;
  final String? nextUrl;
  final String? previousUrl;

  const ArticlePage({
    required this.articles,
    required this.totalCount,
    this.nextUrl,
    this.previousUrl,
  });

  bool get hasNextPage => nextUrl != null && nextUrl!.isNotEmpty;
}

class ArticleRepository {
  final ApiClient _apiClient;

  ArticleRepository(this._apiClient);

  /// Fetch the first page of articles, optionally filtered by search query or news site.
  Future<ArticlePage> getArticles({
    int limit = 10,
    int offset = 0,
    String? searchQuery,
    String? newsSite,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      'ordering': '-published_at',
    };

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      queryParameters['search'] = searchQuery.trim();
    }

    if (newsSite != null && newsSite.trim().isNotEmpty && newsSite != 'All') {
      queryParameters['news_site'] = newsSite.trim();
    }

    final response = await _apiClient.get(
      AppConstants.articlesEndpoint,
      queryParameters: queryParameters,
    );

    return _parseArticlePage(response);
  }

  /// Fetch the next page using the API-provided next URL.
  Future<ArticlePage> getNextPage(String nextUrl) async {
    final uri = Uri.parse(nextUrl);

    final response = await _apiClient.get(
      uri.path.replaceFirst('/v4', ''),
      queryParameters: uri.queryParameters,
    );

    return _parseArticlePage(response);
  }

  /// Fetch a single article using its ID.
  Future<ArticleModel> getArticleDetails(int articleId) async {
    final response = await _apiClient.get(
      '${AppConstants.articlesEndpoint}$articleId/',
    );

    return ArticleModel.fromJson(response);
  }

  /// Convert API response into a typed ArticlePage.
  ArticlePage _parseArticlePage(Map<String, dynamic> response) {
    final results = response['results'];

    if (results is! List) {
      throw const DataParsingException(
        'Invalid articles response: results must be a list.',
      );
    }

    final articles = results
        .whereType<Map<String, dynamic>>()
        .map(ArticleModel.fromJson)
        .toList();

    return ArticlePage(
      articles: articles,
      totalCount: (response['count'] as num?)?.toInt() ?? 0,
      nextUrl: response['next'] as String?,
      previousUrl: response['previous'] as String?,
    );
  }
}
