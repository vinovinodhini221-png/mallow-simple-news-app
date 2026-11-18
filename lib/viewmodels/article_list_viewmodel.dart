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

  String? _nextUrl;
  Timer? _debounceTimer;

  static const int _pageSize = 10;

  // Dynamic news site categories
  List<String> _categories = ['All'];
  List<String> get categories => List.unmodifiable(_categories);
  List<String> get availableCategories => categories;

  int _selectedCategoryIndex = 0;
  int get selectedCategoryIndex => _selectedCategoryIndex;

  bool isLoadingCategories = false;

  /// Returns the currently selected news site name (or 'All').
  String get selectedNewsSite {
    if (_categories.isEmpty ||
        _selectedCategoryIndex < 0 ||
        _selectedCategoryIndex >= _categories.length) {
      return 'All';
    }
    return _categories[_selectedCategoryIndex];
  }

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

      // If categories haven't loaded from /info/ yet, extract from articles as fallback
      if (_categories.length <= 1 && _articles.isNotEmpty) {
        _populateCategoriesFromArticles();
      }
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

  /// Dynamically fetch all available news sites from the API info endpoint.
  Future<void> fetchCategories() async {
    if (isLoadingCategories) return;

    isLoadingCategories = true;
    notifyListeners();

    try {
      final sites = await _repository.getNewsSites();
      if (sites.isNotEmpty) {
        final currentSelection = selectedNewsSite;

        _categories = ['All', ...sites];

        // Maintain matched index for current selection
        final matchedIndex = _categories.indexOf(currentSelection);
        _selectedCategoryIndex = matchedIndex != -1 ? matchedIndex : 0;
      }
    } catch (_) {
      // If fetching fails, extract from articles or keep current categories
      if (_articles.isNotEmpty) {
        _populateCategoriesFromArticles();
      }
    } finally {
      isLoadingCategories = false;
      notifyListeners();
    }
  }

  /// Populate categories dynamically from loaded articles if needed.
  void _populateCategoriesFromArticles() {
    final distinctSites = _articles
        .map((a) => a.newsSite.trim())
        .where((s) => s.isNotEmpty && s != 'Unknown source')
        .toSet()
        .toList();

    if (distinctSites.isNotEmpty) {
      final currentSelection = selectedNewsSite;
      _categories = ['All', ...distinctSites];
      final matched = _categories.indexOf(currentSelection);
      _selectedCategoryIndex = matched != -1 ? matched : 0;
    }
  }

  /// Change category filter by index and re-fetch articles for the matched site.
  void selectCategoryIndex(int index) {
    if (index < 0 || index >= _categories.length) return;
    if (_selectedCategoryIndex == index && _articles.isNotEmpty) return;

    _selectedCategoryIndex = index;
    notifyListeners();
    fetchArticles();
  }

  /// Change category filter by news site name and find the matched index.
  void selectCategory(String category) {
    final index = _categories.indexOf(category);
    if (index != -1) {
      selectCategoryIndex(index);
    } else {
      // If not yet in categories, add it and select it
      _categories.add(category);
      selectCategoryIndex(_categories.length - 1);
    }
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
      // Refresh both categories and articles
      await Future.wait([
        fetchCategories(),
        _fetchArticlesWithoutLoadingIndicator(),
      ]);
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> _fetchArticlesWithoutLoadingIndicator() async {
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
