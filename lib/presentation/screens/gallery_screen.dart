import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:sam_gig/presentation/screens/widgets/category_chips.dart';
import 'package:sam_gig/presentation/screens/widgets/gallery_skeleton.dart';
import 'package:sam_gig/presentation/screens/widgets/image_tile.dart';
import 'package:sam_gig/presentation/screens/widgets/status_view.dart';

import '../../core/error/app_exception.dart';
import '../providers/gallery_provider.dart';
import '../providers/theme_provider.dart';
import 'detail_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {

  static const double _prefetchDistance = 800;
  static const double _maxTileExtent = 220;

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _masonry = true; 

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _prefetchDistance) {
      context.read<GalleryProvider>().loadMore();
    }
  }

  Future<void> _onRefresh() async {
    final messenger = ScaffoldMessenger.of(context);
    final failure = await context.read<GalleryProvider>().refresh();
    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  void _submitSearch(String value) {
    FocusScope.of(context).unfocus();
    context.read<GalleryProvider>().search(value);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    context.read<GalleryProvider>().search('');
  }

  @override
  Widget build(BuildContext context) {
    final gallery = context.watch<GalleryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          IconButton(
            tooltip: _masonry ? 'Switch to uniform grid' : 'Switch to masonry grid',
            icon: Icon(_masonry ? Icons.grid_view_rounded : Icons.dashboard_rounded),
            onPressed: () => setState(() => _masonry = !_masonry),
          ),
          IconButton(
            tooltip: isDark ? 'Light theme' : 'Dark theme',
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => context
                .read<ThemeProvider>()
                .setMode(isDark ? ThemeMode.light : ThemeMode.dark),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search photos',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
              textInputAction: TextInputAction.search,
              onSubmitted: _submitSearch,
              onChanged: (_) => setState(() {}), 
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close),
                    onPressed: _clearSearch,
                  ),
              ],
            ),
          ),
          CategoryChips(
            selected: gallery.category,
            onSelected: context.read<GalleryProvider>().selectCategory,
          ),
          const SizedBox(height: 4),
          Expanded(child: _buildBody(gallery)),
        ],
      ),
    );
  }

  Widget _buildBody(GalleryProvider gallery) {
    if (gallery.isInitialLoading) return const GallerySkeleton();

    if (gallery.error != null && gallery.images.isEmpty) {
      return StatusView(
        icon: gallery.error is NetworkException
            ? Icons.wifi_off_rounded
            : Icons.error_outline_rounded,
        title: 'Oops!',
        message: gallery.error!.message,
        actionLabel: 'Try again',
        onAction: gallery.loadInitial,
      );
    }

    if (gallery.images.isEmpty) {
      return StatusView(
        icon: Icons.image_search_rounded,
        title: 'No images found',
        message: gallery.query.isEmpty
            ? 'Try a different category.'
            : 'Nothing matched "${gallery.query}". Try another search.',
      );
    }

    final images = gallery.images;

    final delegate = SliverChildBuilderDelegate(
      (context, index) {
        final image = images[index];
        return ImageTile(
          key: ValueKey(image.id), 
          image: image,
          heroPrefix: 'gallery',
          keepAspectRatio: _masonry,
          onTap: () => openImageDetail(context, image, heroPrefix: 'gallery'),
        );
      },
      childCount: images.length,
    );

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            sliver: _masonry
                ? SliverMasonryGrid(
                    gridDelegate: const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: _maxTileExtent,
                    ),
                    delegate: delegate,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  )
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: _maxTileExtent,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    delegate: delegate,
                  ),
          ),
          SliverToBoxAdapter(child: _Footer(gallery: gallery)),
        ],
      ),
    );
  }
}


class _Footer extends StatelessWidget {
  const _Footer({required this.gallery});

  final GalleryProvider gallery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (gallery.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (gallery.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(gallery.loadMoreError!.message, textAlign: TextAlign.center),
            TextButton.icon(
              onPressed: gallery.loadMore,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (gallery.hasReachedMax) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            "You've reached the end",
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
          ),
        ),
      );
    }
    return const SizedBox(height: 80);
  }
}