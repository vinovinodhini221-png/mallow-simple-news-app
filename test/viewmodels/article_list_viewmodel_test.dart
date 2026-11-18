import 'package:flutter_test/flutter_test.dart';
import 'package:mallow_tech/core/errors/app_exception.dart';
import 'package:mallow_tech/core/network/api_client.dart';
import 'package:mallow_tech/data/models/article_model.dart';
import 'package:mallow_tech/data/repositories/article_repository.dart';
import 'package:mallow_tech/viewmodels/article_list_viewmodel.dart';

class MockArticleRepository extends ArticleRepository {
  MockArticleRepository() : super(ApiClient());

  bool shouldThrow = false;
  List<ArticleModel> mockArticles = [];
  String? nextUrl;

  @override
  Future<ArticlePage> getArticles({
    int limit = 10,
    int offset = 0,
    String? searchQuery,
    String? newsSite,
  }) async {
    if (shouldThrow) {
      throw const NetworkException('No internet connection');
    }

    return ArticlePage(
      articles: mockArticles,
      totalCount: mockArticles.length,
      nextUrl: nextUrl,
      previousUrl: null,
    );
  }

  @override
  Future<ArticlePage> getNextPage(String nextUrl) async {
    if (shouldThrow) {
      throw const NetworkException('Pagination network failure');
    }

    return ArticlePage(
      articles: mockArticles,
      totalCount: 20,
      nextUrl: null,
      previousUrl: null,
    );
  }
}

void main() {
  group('ArticleListViewModel', () {
    late MockArticleRepository repository;
    late ArticleListViewModel viewModel;

    setUp(() {
      repository = MockArticleRepository();
      viewModel = ArticleListViewModel(repository);
    });

    test('initial state has default values', () {
      expect(viewModel.articles, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.hasError, isFalse);
      expect(viewModel.hasMore, isTrue);
      expect(viewModel.selectedNewsSite, 'All');
    });

    test('fetchArticles sets articles on success', () async {
      repository.mockArticles = [
        const ArticleModel(
          id: 1,
          title: 'Article 1',
          url: 'https://example.com/1',
          newsSite: 'NASA',
        ),
      ];

      await viewModel.fetchArticles();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.hasError, isFalse);
      expect(viewModel.articles.length, 1);
      expect(viewModel.articles.first.title, 'Article 1');
    });

    test('fetchArticles handles error and sets errorMessage', () async {
      repository.shouldThrow = true;

      await viewModel.fetchArticles();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, contains('No internet connection'));
      expect(viewModel.articles, isEmpty);
    });

    test('selectCategory updates selectedNewsSite and triggers fetch', () async {
      repository.mockArticles = [
        const ArticleModel(
          id: 2,
          title: 'NASA News',
          url: 'https://example.com/2',
          newsSite: 'NASA',
        ),
      ];

      viewModel.selectCategory('NASA');

      expect(viewModel.selectedNewsSite, 'NASA');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(viewModel.articles.length, 1);
    });
  });
}
