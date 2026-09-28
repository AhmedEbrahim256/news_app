import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/services/news_api_service.dart';

void main() {
  test('loads live headlines from BBC RSS', () async {
    final articles = await NewsApiService().getTopHeadlines(
      category: 'business',
    );

    expect(articles, isNotEmpty);
    expect(articles.first.title, isNotEmpty);
    expect(
      articles.where((article) => article.urlToImage != null),
      isNotEmpty,
    );
  });

  test('loads live search results', () async {
    final articles = await NewsApiService().searchArticles(query: 'technology');

    expect(articles, isNotEmpty);
    expect(articles.first.title, isNotEmpty);
  });
}
