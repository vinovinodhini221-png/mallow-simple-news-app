import 'package:mallow_tech/core/network/api_client.dart';
import 'package:mallow_tech/core/theme/app_theme.dart';
import 'package:mallow_tech/data/repositories/article_repository.dart';
import 'package:mallow_tech/viewmodels/article_detail_viewmodel.dart';
import 'package:mallow_tech/viewmodels/article_list_viewmodel.dart';
import 'package:mallow_tech/views/screens/article_list_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final ApiClient? apiClient;
  final ArticleRepository? articleRepository;

  const MyApp({
    super.key,
    this.apiClient,
    this.articleRepository,
  });

  @override
  Widget build(BuildContext context) {
    final client = apiClient ?? ApiClient();
    final repo = articleRepository ?? ArticleRepository(client);

    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: client),
        Provider<ArticleRepository>.value(value: repo),
        ChangeNotifierProvider<ArticleListViewModel>(
          create: (_) => ArticleListViewModel(repo),
        ),
        ChangeNotifierProvider<ArticleDetailViewModel>(
          create: (_) => ArticleDetailViewModel(repo),
        ),
      ],
      child: MaterialApp(
        title: 'Mallow News',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const ArticleListScreen(),
      ),
    );
  }
}
