import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/article_model.dart';
import '../screens/article_detail_screen.dart';

class ArticleListTile extends StatelessWidget {
  final Article article;
  final int index;

  const ArticleListTile({
    super.key,
    required this.article,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleDetailScreen(article: article),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Hero(
                  tag: 'article-image-${article.url}',
                  child: CachedNetworkImage(
                    imageUrl: article.urlToImage ?? '',
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                      child: const Center(
                        child: Icon(Icons.image_outlined,
                            color: Colors.white24, size: 40),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                      child: const Center(
                        child: Icon(Icons.article,
                            color: Colors.white54, size: 40),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Category/Source
            Text(
              article.sourceName ?? 'News',
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            // Title
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
