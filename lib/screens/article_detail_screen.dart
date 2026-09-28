import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/article_model.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details News'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                            color: Colors.white24, size: 48),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                      child: const Center(
                        child: Icon(Icons.article,
                            color: Colors.white54, size: 48),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              article.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            
            // Category/Source
            Text(
              article.sourceName ?? 'News',
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 20),
            
            // Content
            if (article.description != null) ...[
              Text(
                article.description!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFCCCCCC),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            if (article.content != null) ...[
              Text(
                article.content!.replaceAll(RegExp(r'\[\+\d+ chars\]'), ''),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFCCCCCC),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }
}
