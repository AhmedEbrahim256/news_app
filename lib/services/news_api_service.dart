import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../core/app_constants.dart';
import '../models/article_model.dart';

class NewsException implements Exception {
  final String message;
  NewsException(this.message);

  @override
  String toString() => message;
}

class NewsApiService {
  late final Dio _dio;

  NewsApiService({Dio? dio}) {
    _dio = dio ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            responseType: ResponseType.plain,
            headers: {
              'Accept': 'application/rss+xml, application/xml, text/xml, */*',
              'User-Agent': 'Mozilla/5.0 (compatible; NewsApp/1.0)',
            },
          ),
        );
  }

  Future<List<Article>> getTopHeadlines({
    String category = 'general',
    String country = 'us',
    int page = 1,
    int pageSize = 20,
  }) async {
    return _fetchFeed(
      AppConstants.feedUrlForCategory(category),
      sourceFallback: 'BBC News',
      limit: pageSize,
    );
  }

  Future<List<Article>> searchArticles({
    required String query,
    int page = 1,
    int pageSize = 20,
    String sortBy = 'publishedAt',
  }) async {
    return _fetchFeed(
      AppConstants.searchFeedUrl(query),
      sourceFallback: 'Google News',
      limit: pageSize,
    );
  }

  Future<List<Article>> _fetchFeed(
    String url, {
    required String sourceFallback,
    required int limit,
  }) async {
    try {
      final response = await _dio.get<String>(url);
      final body = response.data;
      if (response.statusCode != 200 || body == null || body.isEmpty) {
        throw NewsException('Failed to load news.');
      }
      return _parseRss(body, sourceFallback: sourceFallback, limit: limit);
    } on NewsException {
      rethrow;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (_) {
      throw NewsException('Failed to load news.');
    }
  }

  List<Article> _parseRss(
    String xml, {
    required String sourceFallback,
    required int limit,
  }) {
    final document = XmlDocument.parse(xml);
    final items = document.findAllElements('item');
    final articles = <Article>[];

    for (final item in items) {
      final title = _textOf(item, 'title');
      if (title.isEmpty) continue;

      final description = _stripHtml(_textOf(item, 'description'));
      final url = _textOf(item, 'link');
      final sourceName = _textOf(item, 'source').isNotEmpty
          ? _textOf(item, 'source')
          : sourceFallback;
      final imageUrl = _imageUrl(item);
      final publishedAt = _parseRssDate(_textOf(item, 'pubDate'));

      articles.add(
        Article(
          sourceName: sourceName,
          title: title,
          description: description.isEmpty ? null : description,
          url: url.isEmpty ? null : url,
          urlToImage: imageUrl,
          publishedAt: publishedAt,
          content: description.isEmpty ? null : description,
        ),
      );

      if (articles.length >= limit) break;
    }

    return articles;
  }

  String _textOf(XmlElement item, String name) {
    return item.getElement(name)?.innerText.trim() ?? '';
  }

  String? _imageUrl(XmlElement item) {
    for (final node in item.descendants.whereType<XmlElement>()) {
      if (node.localName != 'thumbnail' && node.localName != 'content') {
        continue;
      }
      final url = node.getAttribute('url');
      if (url != null && url.isNotEmpty) {
        return url.replaceFirst('/ace/standard/240/', '/ace/standard/800/');
      }
    }

    final enclosure = item.getElement('enclosure');
    final enclosureUrl = enclosure?.getAttribute('url');
    if (enclosureUrl != null && enclosureUrl.isNotEmpty) {
      return enclosureUrl;
    }

    final description = item.getElement('description')?.innerText ?? '';
    final match = RegExp(r'src="([^"]+)"').firstMatch(description);
    return match?.group(1);
  }

  DateTime? _parseRssDate(String raw) {
    if (raw.isEmpty) return null;
    final cleaned = raw
        .replaceAll(' GMT', '')
        .replaceAll(' +0000', '')
        .replaceAll(RegExp(r' [+-]\d{4}$'), '')
        .trim();
    try {
      return DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_US').parseUtc(cleaned);
    } catch (_) {
      return DateTime.tryParse(raw);
    }
  }

  String _stripHtml(String raw) {
    return raw
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  NewsException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NewsException('Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return NewsException('No internet connection.');
      default:
        return NewsException('Failed to load news.');
    }
  }
}
