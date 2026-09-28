class AppConstants {
  AppConstants._();

  static const List<String> categories = [
    'general',
    'business',
    'technology',
    'science',
    'health',
    'sports',
    'entertainment',
  ];

  static const Map<String, String> categoryFeeds = {
    'general': 'https://feeds.bbci.co.uk/news/rss.xml',
    'business': 'https://feeds.bbci.co.uk/news/business/rss.xml',
    'technology': 'https://feeds.bbci.co.uk/news/technology/rss.xml',
    'science': 'https://feeds.bbci.co.uk/news/science_and_environment/rss.xml',
    'health': 'https://feeds.bbci.co.uk/news/health/rss.xml',
    'sports': 'https://feeds.bbci.co.uk/sport/rss.xml',
    'entertainment': 'https://feeds.bbci.co.uk/news/entertainment_and_arts/rss.xml',
  };

  static String feedUrlForCategory(String category) {
    return categoryFeeds[category] ?? categoryFeeds['general']!;
  }

  static String searchFeedUrl(String query) {
    final encoded = Uri.encodeQueryComponent(query.trim());
    return 'https://news.google.com/rss/search?q=$encoded&hl=en-US&gl=US&ceid=US:en';
  }
}
