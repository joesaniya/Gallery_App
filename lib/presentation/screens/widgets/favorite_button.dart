import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sam_gig/data/models/pixabay_image.dart';
import 'package:sam_gig/presentation/providers/favorites_provider.dart';



class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.image, this.compact = false});

  final PixabayImage image;
  final bool compact;

  @override
  Widget build(BuildContext context) {
  
    final isFavorite = context.select<FavoritesProvider, bool>(
      (p) => p.isFavorite(image.id),
    );

    return IconButton.filledTonal(
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.redAccent : null,
      ),
      onPressed: () async {
        // Grab the messenger BEFORE the await (BuildContext safety).
        final messenger = ScaffoldMessenger.of(context);
        final ok = await context.read<FavoritesProvider>().toggle(image);
        if (!ok) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Could not update favorites. Please try again.'),
            ),
          );
        }
      },
    );
  }
}
