import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class Article extends Equatable {
  final String title;
  final String? sourceName;
  final String? description;
  final String? url;
  final String? imageUrl;
  final DateTime? publishedAt;

  const Article({
    required this.title,
    this.sourceName,
    this.description,
    this.url,
    this.imageUrl,
    this.publishedAt,
  });

  String heroTag(int index) => 'article-$index-${url ?? title}';

  String get timeLabel {
    final date = publishedAt;
    if (date == null) return '';

    final diff = DateTime.now().difference(date);
    if (diff.isNegative) {
      return DateFormat('MMM d').format(date);
    }
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  bool get isRecent {
    final date = publishedAt;
    if (date == null) return false;
    final diff = DateTime.now().difference(date);
    return !diff.isNegative && diff.inHours < 3;
  }

  @override
  List<Object?> get props => [
        title,
        sourceName,
        description,
        url,
        imageUrl,
        publishedAt,
      ];
}
