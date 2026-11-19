import 'package:flutter_test/flutter_test.dart';
import 'package:mallow_news_app/core/network/api_client.dart';
import 'package:mallow_news_app/data/models/article_model.dart';
import 'package:mallow_news_app/data/repositories/article_repository.dart';
import 'package:mallow_news_app/main.dart';
import 'package:material_ui/material_ui.dart';

class FakeArticleRepository extends ArticleRepository {
  FakeArticleRepository() : super(ApiClient());

  @override
  Future<ArticlePage> getArticles({
    int limit = 10,
    int offset = 0,
    String? searchQuery,
    String? newsSite,
  }) async {
    return const ArticlePage(
      articles: [
        ArticleModel(
          id: 1,
          title: 'Discover SpaceX Launch',
          url: 'https://example.com/spacex',
          newsSite: 'NASA',
          summary: 'A rocket was launched into orbit.',
        ),
      ],
      totalCount: 1,
      nextUrl: null,
      previousUrl: null,
    );
  }

  @override
  Future<ArticleModel> getArticleDetails(int articleId) async {
    return const ArticleModel(
      id: 1,
      title: 'Discover SpaceX Launch',
      url: 'https://example.com/spacex',
      newsSite: 'NASA',
      summary: 'A rocket was launched into orbit.',
    );
  }

  @override
  Future<List<String>> getNewsSites() async {
    return ['NASA', 'SpaceNews'];
  }
}

void main() {
  testWidgets('App renders Discover header and article list', (tester) async {
    final fakeRepo = FakeArticleRepository();

    await tester.pumpWidget(MyApp(articleRepository: fakeRepo));
    await tester.pumpAndSettle();

    // Verify Discover header & subtitle
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('News from all around the world'), findsOneWidget);

    // Verify search field
    expect(find.byType(TextField), findsOneWidget);

    // Verify category chips
    expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'NASA'), findsOneWidget);

    // Verify article card
    expect(find.text('Discover SpaceX Launch'), findsOneWidget);
  });
}
