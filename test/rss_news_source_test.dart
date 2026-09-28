import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/rep/data_source/rss_news_source.dart';
import 'package:news_app/rep/news_repository.dart';

const _sampleRss = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
  <channel>
    <item>
      <title>Sample headline</title>
      <description>A short summary of the story.</description>
      <link>https://www.bbc.co.uk/news/sample</link>
      <pubDate>Sun, 27 Sep 2026 10:00:00 GMT</pubDate>
      <media:thumbnail url="https://ichef.bbci.co.uk/ace/standard/240/sample.jpg"/>
    </item>
    <item>
      <title></title>
      <description>Should be skipped</description>
    </item>
    <item>
      <title>Second story</title>
      <description>&lt;p&gt;HTML &amp;amp; entities&lt;/p&gt;</description>
      <link>https://www.bbc.co.uk/news/second</link>
      <source>BBC News</source>
    </item>
  </channel>
</rss>
''';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body, {this.statusCode = 200});

  final String body;
  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/xml'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('parses rss items and skips empty titles', () async {
    final dio = Dio()..httpClientAdapter = _FakeAdapter(_sampleRss);
    final source = RssNewsSource(dio: dio);

    final articles = await source.getHeadlines('business');

    expect(articles.length, 2);
    expect(articles.first.title, 'Sample headline');
    expect(
      articles.first.imageUrl,
      'https://ichef.bbci.co.uk/ace/standard/800/sample.jpg',
    );
    expect(articles[1].description, 'HTML & entities');
  });

  test('search uses the same parser', () async {
    final dio = Dio()..httpClientAdapter = _FakeAdapter(_sampleRss);
    final source = RssNewsSource(dio: dio);

    final articles = await source.search('technology');

    expect(articles, isNotEmpty);
    expect(articles.first.url, 'https://www.bbc.co.uk/news/sample');
  });

  test('throws a NewsException on a bad response', () async {
    final dio = Dio()..httpClientAdapter = _FakeAdapter('', statusCode: 500);
    final source = RssNewsSource(dio: dio);

    expect(
      () => source.getHeadlines('general'),
      throwsA(isA<NewsException>()),
    );
  });
}
