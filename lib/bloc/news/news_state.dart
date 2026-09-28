part of 'news_bloc.dart';

enum NewsStatus { initial, loading, success, failure }

class NewsState extends Equatable {
  final NewsStatus status;
  final List<Article> articles;
  final List<Article> searchResults;
  final String selectedCategory;
  final String errorMessage;
  final bool isSearching;
  final String searchQuery;

  const NewsState({
    this.status = NewsStatus.initial,
    this.articles = const [],
    this.searchResults = const [],
    this.selectedCategory = 'general',
    this.errorMessage = '',
    this.isSearching = false,
    this.searchQuery = '',
  });

  NewsState copyWith({
    NewsStatus? status,
    List<Article>? articles,
    List<Article>? searchResults,
    String? selectedCategory,
    String? errorMessage,
    bool? isSearching,
    String? searchQuery,
  }) {
    return NewsState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      searchResults: searchResults ?? this.searchResults,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage ?? this.errorMessage,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        articles,
        searchResults,
        selectedCategory,
        errorMessage,
        isSearching,
        searchQuery,
      ];
}
