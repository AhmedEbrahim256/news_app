import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/news/news_bloc.dart';
import '../widgets/article_list_tile.dart';
import '../widgets/category_selector.dart';
import '../widgets/featured_news_card.dart';
import '../widgets/news_shimmer_loading.dart';
import '../core/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() => _isSearchVisible = true);
  }

  void _closeSearch(BuildContext context) {
    _searchController.clear();
    context.read<NewsBloc>().add(ClearSearch());
    setState(() => _isSearchVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search news...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onSubmitted: (query) {
                  final trimmed = query.trim();
                  if (trimmed.isNotEmpty) {
                    context.read<NewsBloc>().add(SearchNews(trimmed));
                  }
                },
              )
            : const Text('News App'),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: () {
              if (_isSearchVisible) {
                _closeSearch(context);
              } else {
                _startSearch();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<NewsBloc, NewsState>(
          builder: (context, state) {
            return Column(
              children: [
                if (!state.isSearching)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: CategorySelector(
                      selectedCategory: state.selectedCategory,
                      onCategorySelected: (category) {
                        if (category != state.selectedCategory) {
                          context.read<NewsBloc>().add(ChangeCategory(category));
                        }
                      },
                    ),
                  ),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NewsState state) {
    if (state.status == NewsStatus.loading) {
      return const NewsShimmerLoading();
    }

    if (state.status == NewsStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 64, color: AppTheme.accentColor.withValues(alpha: 0.8)),
              const SizedBox(height: 16),
              Text(
                'Failed to load news',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<NewsBloc>().add(RefreshNews());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final articles = state.isSearching ? state.searchResults : state.articles;

    if (articles.isEmpty && state.status == NewsStatus.success) {
      return Center(
        child: Text(
          state.isSearching
              ? 'No results for "${state.searchQuery}"'
              : 'No articles found',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<NewsBloc>().add(RefreshNews());
        await context
            .read<NewsBloc>()
            .stream
            .firstWhere((s) => s.status != NewsStatus.loading);
      },
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          // Show the first top-headline as a large featured card; everything
          // else (and every search result) is a regular list tile.
          if (!state.isSearching && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: FeaturedNewsCard(article: articles[0]),
            );
          }
          return ArticleListTile(article: articles[index], index: index);
        },
      ),
    );
  }
}
