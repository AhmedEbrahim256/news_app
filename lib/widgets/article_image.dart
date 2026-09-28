import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class ArticleImage extends StatelessWidget {
  const ArticleImage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  final String? imageUrl;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallback = ColoredBox(
      color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      child: Center(
        child: Icon(
          Icons.article_outlined,
          size: 48,
          color: isDark ? Colors.white54 : Colors.black26,
        ),
      ),
    );

    final url = imageUrl;
    final image = (url == null || url.isEmpty)
        ? fallback
        : CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (context, _) => fallback,
            errorWidget: (context, _, _) => fallback,
          );

    return Hero(tag: heroTag, child: image);
  }
}
