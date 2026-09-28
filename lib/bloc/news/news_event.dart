part of 'news_bloc.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

class FetchTopHeadlines extends NewsEvent {
  const FetchTopHeadlines({this.category = 'general'});

  final String category;

  @override
  List<Object?> get props => [category];
}

class ChangeCategory extends NewsEvent {
  const ChangeCategory(this.category);

  final String category;

  @override
  List<Object?> get props => [category];
}

class SearchNews extends NewsEvent {
  const SearchNews(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends NewsEvent {}

class RefreshNews extends NewsEvent {
  // ignore: prefer_const_constructors_in_immutables
  RefreshNews([this._done]);

  final Completer<void>? _done;

  void complete() {
    final done = _done;
    if (done != null && !done.isCompleted) {
      done.complete();
    }
  }
}
