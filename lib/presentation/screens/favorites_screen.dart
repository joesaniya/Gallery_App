import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:sam_gig/presentation/screens/widgets/image_tile.dart';
import 'package:sam_gig/presentation/screens/widgets/status_view.dart';

import '../providers/favorites_provider.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? const StatusView(
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              message: 'Tap the heart on any image to save it here.',
            )
          : MasonryGridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
              ),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final image = favorites[index];
                return ImageTile(
                  key: ValueKey(image.id),
                  image: image,
                  heroPrefix: 'favorites',
                  onTap: () => openImageDetail(context, image, heroPrefix: 'favorites'),
                );
              },
            ),
    );
  }
}