import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sam_gig/data/models/pixabay_image.dart';
import 'favorite_button.dart';


class ImageTile extends StatelessWidget {
  const ImageTile({
    super.key,
    required this.image,
    required this.heroPrefix,
    required this.onTap,
    this.keepAspectRatio = true,
  });

  final PixabayImage image;

  
  final String heroPrefix;
  final VoidCallback onTap;

  
  final bool keepAspectRatio;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        
        final cacheWidth = (constraints.maxWidth * pixelRatio).round();

        Widget picture = Hero(
          tag: '${heroPrefix}_${image.id}',
          child: CachedNetworkImage(
            imageUrl: image.webformatUrl,
            fit: BoxFit.cover,
            memCacheWidth: cacheWidth,
            fadeInDuration: const Duration(milliseconds: 200),
            placeholder: (_, __) => ColoredBox(color: scheme.surfaceContainerHighest),
            errorWidget: (_, __, ___) => ColoredBox(
              color: scheme.surfaceContainerHighest,
              child: Icon(Icons.broken_image_outlined, color: scheme.outline),
            ),
          ),
        );

        if (keepAspectRatio) {
          picture = AspectRatio(aspectRatio: image.aspectRatio, child: picture);
        }

        return Semantics(
          button: true,
          label: image.description,
          child: GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  picture,
                  Positioned(
                    top: 6,
                    right: 6,
                    child: FavoriteButton(image: image, compact: true),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}