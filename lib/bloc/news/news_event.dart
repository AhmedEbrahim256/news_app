part of 'news_bloc.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch top headlines for a specific category
class FetchTopHeadlines extends NewsEvent {
  final String category;

  const FetchTopHeadlines({this.category = 'general'});

  @override
  List<Object?> get props => [category];
}

/// Change selected category
class ChangeCategory extends NewsEvent {
  final String category;

  const ChangeCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Search news articles
class SearchNews extends NewsEvent {
  final String query;

  const SearchNews(this.query);

  @override
  List<Object?> get props => [query];
}

/// Clear search results and go back
class ClearSearch extends NewsEvent {}

/// Refresh current news
class RefreshNews extends NewsEvent {}
