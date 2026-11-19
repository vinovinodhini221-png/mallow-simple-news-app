import 'package:flutter/foundation.dart';
import 'package:mallow_news_app/core/errors/app_exception.dart';
import 'package:mallow_news_app/data/models/article_model.dart';
import 'package:mallow_news_app/data/repositories/article_repository.dart';


class ArticleDetailViewModel extends ChangeNotifier {
  final ArticleRepository _repository;

  ArticleDetailViewModel(this._repository);

  ArticleModel? _article;
  ArticleModel? get article => _article;

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadArticle(int articleId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _article = await _repository.getArticleDetails(articleId);
    } on AppException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Unable to load article details.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setArticle(ArticleModel article) {
    _article = article;
    errorMessage = null;
    notifyListeners();
  }

  void clearArticle() {
    _article = null;
    errorMessage = null;
    notifyListeners();
  }
}
