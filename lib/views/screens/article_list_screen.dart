import 'package:mallow_tech/viewmodels/article_list_viewmodel.dart';
import 'package:mallow_tech/views/screens/article_detail_screen.dart';
import 'package:mallow_tech/views/widgets/article_card.dart';
import 'package:mallow_tech/views/widgets/empty_widget.dart';
import 'package:mallow_tech/views/widgets/error_widget.dart';
import 'package:mallow_tech/views/widgets/loading_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class ArticleListScreen extends StatefulWidget {
  const ArticleListScreen({super.key});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ArticleListViewModel>().fetchArticles();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<ArticleListViewModel>().loadMoreArticles();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer<ArticleListViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                _buildSearchField(viewModel),
                _buildCategoryChips(viewModel, theme),
                const SizedBox(height: 8),
                Expanded(child: _buildArticleContent(viewModel)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'News from all around the world',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ArticleListViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: viewModel.searchArticles,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    viewModel.searchArticles('');
                  },
                )
              : const Icon(Icons.tune_rounded),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ArticleListViewModel viewModel, ThemeData theme) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: ArticleListViewModel.availableCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = ArticleListViewModel.availableCategories[index];
          final isSelected = viewModel.selectedNewsSite == category;

          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => viewModel.selectCategory(category),
            selectedColor: theme.colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            backgroundColor: theme.colorScheme.surface,
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildArticleContent(ArticleListViewModel viewModel) {
    if (viewModel.isLoading && viewModel.articles.isEmpty) {
      return const LoadingWidget();
    }

    if (viewModel.hasError && viewModel.articles.isEmpty) {
      return AppErrorWidget(
        message: viewModel.errorMessage ?? 'Unable to load articles.',
        onRetry: viewModel.fetchArticles,
      );
    }

    if (viewModel.articles.isEmpty) {
      final isSearching = viewModel.searchQuery.isNotEmpty;
      return EmptyWidget(
        message: isSearching
            ? 'No results found for "${viewModel.searchQuery}"'
            : 'No articles available.',
        subtitle: isSearching
            ? 'Try searching with different keywords or check spelling.'
            : 'Try selecting another category or check back later.',
        onRetry: viewModel.fetchArticles,
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshArticles,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 700;

          if (isTablet) {
            return GridView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth >= 1000 ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: viewModel.articles.length + 1,
              itemBuilder: (context, index) {
                if (index == viewModel.articles.length) {
                  return _buildPaginationFooter(viewModel);
                }

                return ArticleCard(
                  article: viewModel.articles[index],
                  isGrid: true,
                  onTap: () => _navigateToDetail(index),
                );
              },
            );
          }

          return ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: viewModel.articles.length + 1,
            separatorBuilder: (_, index) {
              if (index == viewModel.articles.length - 1) {
                return const SizedBox.shrink();
              }
              return const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              if (index == viewModel.articles.length) {
                return _buildPaginationFooter(viewModel);
              }

              return ArticleCard(
                article: viewModel.articles[index],
                isGrid: false,
                onTap: () => _navigateToDetail(index),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(initialIndex: index),
      ),
    );
  }

  Widget _buildPaginationFooter(ArticleListViewModel viewModel) {
    if (viewModel.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (viewModel.paginationError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                viewModel.paginationError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: viewModel.retryPagination,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry loading more'),
              ),
            ],
          ),
        ),
      );
    }

    if (!viewModel.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'You are all caught up!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: 24);
  }
}
