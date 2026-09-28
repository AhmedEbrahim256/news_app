import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_theme.dart';
import '../models/article_model.dart';
import '../widgets/article_image.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({
    super.key,
    required this.article,
    required this.heroIndex,
  });

  final Article article;
  final int heroIndex;

  Future<void> _openArticle(BuildContext context) async {
    final link = article.url;
    if (link == null) return;

    final uri = Uri.tryParse(link);
    if (uri == null) return;

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the article.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyColor = theme.colorScheme.onSurface.withValues(alpha: 0.8);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ArticleImage(
                  imageUrl: article.imageUrl,
                  heroTag: article.heroTag(heroIndex),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              article.title,
              style: theme.textTheme.headlineMedium?.copyWith(height: 1.3),
            ),
            const SizedBox(height: 8),
            Text(
              [
                article.sourceName ?? 'News',
                if (article.timeLabel.isNotEmpty) article.timeLabel,
              ].join('  ·  '),
              style: theme.textTheme.labelSmall,
            ),
            if (article.description != null) ...[
              const SizedBox(height: 20),
              Text(
                article.description!,
                style: theme.textTheme.bodyLarge?.copyWith(color: bodyColor),
              ),
            ],
            if (article.url != null) ...[
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openArticle(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Read full article'),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
