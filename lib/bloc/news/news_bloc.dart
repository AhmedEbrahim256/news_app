import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/article_model.dart';
import '../../services/news_api_service.dart';

part 'news_event.dart';
part 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsApiService _newsApiService;

  NewsBloc({required NewsApiService newsApiService})
      : _newsApiService = newsApiService,
        super(const NewsState()) {
    on<FetchTopHeadlines>(_onFetchTopHeadlines);
    on<ChangeCategory>(_onChangeCategory);
    on<SearchNews>(_onSearchNews);
    on<ClearSearch>(_onClearSearch);
    on<RefreshNews>(_onRefreshNews);
  }

  Future<void> _onFetchTopHeadlines(
    FetchTopHeadlines event,
    Emitter<NewsState> emit,
  ) async {
    emit(state.copyWith(status: NewsStatus.loading));

    try {
      final articles = await _newsApiService.getTopHeadlines(
        category: event.category,
      );
      emit(state.copyWith(
        status: NewsStatus.success,
        articles: articles,
        selectedCategory: event.category,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NewsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChangeCategory(
    ChangeCategory event,
    Emitter<NewsState> emit,
  ) async {
    emit(state.copyWith(
      status: NewsStatus.loading,
      selectedCategory: event.category,
      isSearching: false,
      searchQuery: '',
    ));

    try {
      final articles = await _newsApiService.getTopHeadlines(
        category: event.category,
      );
      emit(state.copyWith(
        status: NewsStatus.success,
        articles: articles,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NewsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearchNews(
    SearchNews event,
    Emitter<NewsState> emit,
  ) async {
    if (event.query.trim().isEmpty) return;

    emit(state.copyWith(
      status: NewsStatus.loading,
      isSearching: true,
      searchQuery: event.query,
    ));

    try {
      final results = await _newsApiService.searchArticles(
        query: event.query,
      );
      emit(state.copyWith(
        status: NewsStatus.success,
        searchResults: results,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NewsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<NewsState> emit,
  ) {
    emit(state.copyWith(
      isSearching: false,
      searchQuery: '',
      searchResults: [],
    ));
  }

  Future<void> _onRefreshNews(
    RefreshNews event,
    Emitter<NewsState> emit,
  ) async {
    try {
      if (state.isSearching && state.searchQuery.isNotEmpty) {
        final results = await _newsApiService.searchArticles(
          query: state.searchQuery,
        );
        emit(state.copyWith(
          status: NewsStatus.success,
          searchResults: results,
        ));
      } else {
        final articles = await _newsApiService.getTopHeadlines(
          category: state.selectedCategory,
        );
        emit(state.copyWith(
          status: NewsStatus.success,
          articles: articles,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: NewsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
