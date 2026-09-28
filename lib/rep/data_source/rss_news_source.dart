import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../../core/app_constants.dart';
import '../../models/article_model.dart';
import '../news_repository.dart';

class RssNewsSource implements NewsRepository {
  RssNewsSource({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                responseType: ResponseType.plain,
                headers: {
                  'Accept': 'application/rss+xml, application/xml, text/xml',
                  'User-Agent': 'Mozilla/5.0 (compatible; NewsApp/1.0)',
                },
              ),
            );

  final Dio _dio;

  @override
  Future<List<Article>> getHeadlines(String category) {
    return _load(
      AppConstants.feedUrlForCategory(category),
      fallbackSource: 'BBC News',
    );
  }

  @override
  Future<List<Article>> search(String query) {
    return _load(
      AppConstants.searchFeedUrl(query),
      fallbackSource: 'Google News',
    );
  }

  Future<List<Article>> _load(String url, {required String fallbackSource}) async {
    try {
      final response = await _dio.get<String>(url);
      final xml = response.data;
      if (response.statusCode != 200 || xml == null || xml.isEmpty) {
        throw NewsException('Failed to load news.');
      }
      return _parseRss(xml, fallbackSource);
    } on NewsException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (_) {
      throw NewsException('Failed to load news.');
    }
  }

  List<Article> _parseRss(String xml, String fallbackSource) {
    final items = XmlDocument.parse(xml).findAllElements('item');
    final articles = <Article>[];

    for (final item in items) {
      final title = _text(item, 'title');
      if (title.isEmpty) continue;

      final description = _stripHtml(_text(item, 'description'));
      final link = _text(item, 'link');
      final source = _text(item, 'source');

      articles.add(
        Article(
          title: title,
          sourceName: source.isNotEmpty ? source : fallbackSource,
          description: description.isEmpty ? null : description,
          url: link.isEmpty ? null : link,
          imageUrl: _readImage(item),
          publishedAt: _readDate(_text(item, 'pubDate')),
        ),
      );

      if (articles.length >= 20) break;
    }

    return articles;
  }

  String _text(XmlElement item, String name) {
    return item.getElement(name)?.innerText.trim() ?? '';
  }

  String? _readImage(XmlElement item) {
    for (final node in item.descendants.whereType<XmlElement>()) {
      if (node.localName != 'thumbnail' && node.localName != 'content') {
        continue;
      }
      final url = node.getAttribute('url');
      if (url != null && url.isNotEmpty) {
        return url.replaceFirst('/ace/standard/240/', '/ace/standard/800/');
      }
    }

    final enclosure = item.getElement('enclosure')?.getAttribute('url');
    if (enclosure != null && enclosure.isNotEmpty) return enclosure;

    final html = item.getElement('description')?.innerText ?? '';
    return RegExp(r'src="([^"]+)"').firstMatch(html)?.group(1);
  }

  DateTime? _readDate(String raw) {
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

  NewsException _mapDioError(DioException e) {
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
