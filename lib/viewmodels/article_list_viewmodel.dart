import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mallow_tech/core/errors/app_exception.dart';
import 'package:mallow_tech/data/models/article_model.dart';
import 'package:mallow_tech/data/repositories/article_repository.dart';

class ArticleListViewModel extends ChangeNotifier {
  final ArticleRepository _repository;

  ArticleListViewModel(this._repository);

  final List<ArticleModel> _articles = [];
  List<ArticleModel> get articles => List.unmodifiable(_articles);

  bool isLoading = false;
  bool isLoadingMore = false;
  bool isRefreshing = false;
  bool hasError = false;
  bool hasMore = true;

  String? errorMessage;
  String? paginationError;
  String searchQuery = '';
  String selectedNewsSite = 'All';

  String? _nextUrl;
  Timer? _debounceTimer;

  static const int _pageSize = 10;

  /// Available news site categories (adapted from design reference).
  static const List<String> availableCategories = [
    'All',
    'NASA',
    'SpaceNews',
    'Spaceflight Now',
    'Ars Technica',
    'Teslarati',
    'Space Policy Online',
  ];

  /// Initial load or filter-triggered fetch.
  Future<void> fetchArticles() async {
    if (isLoading) return;

    isLoading = true;
    hasError = false;
    errorMessage = null;
    paginationError = null;
    notifyListeners();

    try {
      final page = await _repository.getArticles(
        limit: _pageSize,
        searchQuery: searchQuery,
        newsSite: selectedNewsSite,
      );

      _articles
        ..clear()
        ..addAll(page.articles);

      _nextUrl = page.nextUrl;
      hasMore = page.hasNextPage;
    } on AppException catch (e) {
      hasError = true;
      errorMessage = e.message;
    } catch (_) {
      hasError = true;
      errorMessage = 'Unable to load articles. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Change category filter and re-fetch articles.
  void selectCategory(String category) {
    if (selectedNewsSite == category) return;
    selectedNewsSite = category;
    notifyListeners();
    fetchArticles();
  }

  /// Load more articles when scrolling near the bottom.
  Future<void> loadMoreArticles() async {
    if (isLoading || isLoadingMore || !hasMore || _nextUrl == null) {
      return;
    }

    isLoadingMore = true;
    paginationError = null;
    notifyListeners();

    try {
      final page = await _repository.getNextPage(_nextUrl!);

      final existingIds = _articles.map((article) => article.id).toSet();

      for (final article in page.articles) {
        if (existingIds.add(article.id)) {
          _articles.add(article);
        }
      }

      _nextUrl = page.nextUrl;
      hasMore = page.hasNextPage;
    } on AppException catch (e) {
      paginationError = e.message;
    } catch (_) {
      paginationError = 'Unable to load more articles.';
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh.
  Future<void> refreshArticles() async {
    if (isRefreshing) return;

    isRefreshing = true;
    notifyListeners();

    try {
      final page = await _repository.getArticles(
        limit: _pageSize,
        searchQuery: searchQuery,
        newsSite: selectedNewsSite,
      );

      _articles
        ..clear()
        ..addAll(page.articles);

      _nextUrl = page.nextUrl;
      hasMore = page.hasNextPage;
      hasError = false;
      errorMessage = null;
      paginationError = null;
    } on AppException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Unable to refresh articles.';
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  /// Search with a 500ms debounce.
  void searchArticles(String query) {
    searchQuery = query.trim();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchArticles();
    });
  }

  /// Retry pagination after an error in the footer.
  Future<void> retryPagination() async {
    await loadMoreArticles();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
