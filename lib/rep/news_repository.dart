import '../models/article_model.dart';

abstract class NewsRepository {
  Future<List<Article>> getHeadlines(String category);

  Future<List<Article>> search(String query);
}

class NewsException implements Exception {
  NewsException(this.message);

  final String message;

  @override
  String toString() => message;
}
