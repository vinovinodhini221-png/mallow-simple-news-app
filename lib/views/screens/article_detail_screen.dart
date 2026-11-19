import 'package:cached_network_image/cached_network_image.dart';
import 'package:mallow_news_app/core/utils/date_formatter.dart';
import 'package:mallow_news_app/data/models/article_model.dart';
import 'package:mallow_news_app/viewmodels/article_detail_viewmodel.dart';
import 'package:mallow_news_app/viewmodels/article_list_viewmodel.dart';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailScreen extends StatefulWidget {
  final int initialIndex;

  const ArticleDetailScreen({super.key, required this.initialIndex});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentArticle();
    });
  }

  void _loadCurrentArticle() {
    if (!mounted) return;

    final listViewModel = context.read<ArticleListViewModel>();
    final detailViewModel = context.read<ArticleDetailViewModel>();

    if (listViewModel.articles.isEmpty) return;
    if (_currentIndex < 0 || _currentIndex >= listViewModel.articles.length) {
      return;
    }

    final article = listViewModel.articles[_currentIndex];
    detailViewModel.loadArticle(article.id);

    // Prefetch next page if approaching end of loaded list
    if (_currentIndex >= listViewModel.articles.length - 2 &&
        listViewModel.hasMore) {
      listViewModel.loadMoreArticles();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _loadCurrentArticle();
  }

  Future<void> _openOriginalArticle(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      _showMessage('Original article link is unavailable.');
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _showMessage('Unable to open the article link.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to open the article link.');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ArticleListViewModel, ArticleDetailViewModel>(
      builder: (context, listViewModel, detailViewModel, _) {
        final articles = listViewModel.articles;

        if (articles.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Article Details')),
            body: const Center(child: Text('No article available.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Article Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
                onPressed: () {
                  setState(() {
                    _isBookmarked = !_isBookmarked;
                  });
                  _showMessage(
                    _isBookmarked
                        ? 'Article saved to bookmarks.'
                        : 'Article removed from bookmarks.',
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: PageView.builder(
            controller: _pageController,
            reverse: true, // Enables swipe-left for previous and swipe-right for next
            itemCount: articles.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final listArticle = articles[index];
              final detailArticle =
                  detailViewModel.article?.id == listArticle.id
                  ? detailViewModel.article!
                  : listArticle;

              return _buildArticleContent(
                context,
                detailArticle,
                detailViewModel,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildArticleContent(
    BuildContext context,
    ArticleModel article,
    ArticleDetailViewModel detailViewModel,
  ) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 700;
        final imageHeight = isTablet ? 380.0 : 260.0;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: imageHeight,
                      child:
                          article.imageUrl != null &&
                              article.imageUrl!.trim().isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: article.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // News Site Badge & Published Date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              article.newsSite,
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormatter.format(article.publishedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Article Title
                  Text(
                    article.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Divider
                  Divider(color: Colors.grey.withValues(alpha: 0.2)),

                  const SizedBox(height: 16),

                  // Summary Header
                  Text(
                    'Summary',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Summary Content
                  Text(
                    article.summary?.trim().isNotEmpty == true
                        ? article.summary!
                        : 'No summary is available for this article.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.7,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // "Read Full Article" Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: article.url.isNotEmpty
                          ? () => _openOriginalArticle(article.url)
                          : null,
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text(
                        'Read Full Article',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }
}
