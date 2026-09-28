import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/article_model.dart';
import '../../rep/news_repository.dart';

part 'news_event.dart';
part 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  NewsBloc({required this._repository})
      : super(const NewsState()) {
    on<FetchTopHeadlines>(_onFetch, transformer: restartable());
    on<ChangeCategory>(_onChangeCategory, transformer: restartable());
    on<SearchNews>(_onSearch, transformer: restartable());
    on<ClearSearch>(_onClearSearch);
    on<RefreshNews>(_onRefresh, transformer: restartable());
  }

  final NewsRepository _repository;

  Future<void> _onFetch(
    FetchTopHeadlines event,
    Emitter<NewsState> emit,
  ) {
    return _loadHeadlines(event.category, emit, showLoading: true);
  }

  Future<void> _onChangeCategory(
    ChangeCategory event,
    Emitter<NewsState> emit,
  ) {
    return _loadHeadlines(event.category, emit, showLoading: true);
  }

  Future<void> _loadHeadlines(
    String category,
    Emitter<NewsState> emit, {
    required bool showLoading,
  }) async {
    if (showLoading) {
      emit(state.copyWith(
        status: NewsStatus.loading,
        selectedCategory: category,
        isSearching: false,
        searchQuery: '',
      ));
    }

    try {
      final articles = await _repository.getHeadlines(category);
      emit(state.copyWith(
        status: NewsStatus.success,
        articles: articles,
        selectedCategory: category,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NewsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearch(
    SearchNews event,
    Emitter<NewsState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) return;

    emit(state.copyWith(
      status: NewsStatus.loading,
      isSearching: true,
      searchQuery: query,
    ));

    try {
      final results = await _repository.search(query);
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

  void _onClearSearch(ClearSearch event, Emitter<NewsState> emit) {
    emit(state.copyWith(
      isSearching: false,
      searchQuery: '',
      searchResults: const [],
    ));
  }

  Future<void> _onRefresh(
    RefreshNews event,
    Emitter<NewsState> emit,
  ) async {
    final keepList = state.status == NewsStatus.success &&
        (state.isSearching ? state.searchResults : state.articles).isNotEmpty;

    if (!keepList) {
      emit(state.copyWith(status: NewsStatus.loading));
    }

    try {
      if (state.isSearching && state.searchQuery.isNotEmpty) {
        final results = await _repository.search(state.searchQuery);
        emit(state.copyWith(
          status: NewsStatus.success,
          searchResults: results,
        ));
      } else {
        final articles = await _repository.getHeadlines(state.selectedCategory);
        emit(state.copyWith(
          status: NewsStatus.success,
          articles: articles,
        ));
      }
    } catch (e) {
      if (!keepList) {
        emit(state.copyWith(
          status: NewsStatus.failure,
          errorMessage: e.toString(),
        ));
      }
    } finally {
      event.complete();
    }
  }
}
