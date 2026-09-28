import 'package:flutter/material.dart';

import '../models/article_model.dart';
import '../screens/article_detail_screen.dart';
import 'article_image.dart';

class ArticleListTile extends StatelessWidget {
  const ArticleListTile({
    super.key,
    required this.article,
    required this.index,
  });

  final Article article;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleDetailScreen(
            article: article,
            heroIndex: index,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ArticleImage(
                  imageUrl: article.imageUrl,
                  heroTag: article.heroTag(index),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              article.sourceName ?? 'News',
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Text(
              article.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(
                height: 1.3,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
