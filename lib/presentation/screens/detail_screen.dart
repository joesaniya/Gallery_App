import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sam_gig/presentation/screens/widgets/favorite_button.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/error/app_exception.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/pixabay_image.dart';
import '../../data/services/download_service.dart';



void openImageDetail(
  BuildContext context,
  PixabayImage image, {
  required String heroPrefix,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DetailScreen(image: image, heroTag: '${heroPrefix}_${image.id}'),
    ),
  );
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.image, required this.heroTag});

  final PixabayImage image;
  final String heroTag;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {

  double? _progress;
  CancelToken? _cancelToken;

  bool get _isDownloading => _progress != null;

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> _download() async {
    if (_isDownloading) return;

    final messenger = ScaffoldMessenger.of(context);
    final service = context.read<DownloadService>();
    final token = CancelToken();
    _cancelToken = token;
    setState(() => _progress = 0);

    try {
      await service.saveToGallery(
        widget.image,
        cancelToken: token,
        onProgress: (value) {
          if (mounted) setState(() => _progress = value);
        },
      );
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Saved to your gallery.')));
    } on AppException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  Future<void> _share() async {
    try {
      await Share.share('${widget.image.description}\n${widget.image.pageUrl}');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the share sheet.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 840;

         
          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 3, child: _buildPreview(context)),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(child: _buildInfo(context)),
                ),
              ],
            );
          }

          
          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.5,
                    width: double.infinity,
                    child: _buildPreview(context),
                  ),
                  _buildInfo(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildPreview(BuildContext context) {
    final image = widget.image;
    return InteractiveViewer(
      maxScale: 4,
      child: Hero(
        tag: widget.heroTag,
        child: CachedNetworkImage(
          imageUrl: image.largeImageUrl,
          fit: BoxFit.contain,
          placeholder: (_, __) => Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(imageUrl: image.webformatUrl, fit: BoxFit.contain),
              const Center(child: CircularProgressIndicator()),
            ],
          ),
          errorWidget: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image_outlined, size: 64),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final theme = Theme.of(context);
    final image = widget.image;
    final progress = _progress;
    final title = image.tagList.isEmpty ? 'Untitled image' : capitalize(image.tagList.first);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
        
          Text(image.description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: image.userImageUrl.isEmpty
                    ? null
                    : CachedNetworkImageProvider(image.userImageUrl),
                child: image.userImageUrl.isEmpty
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Photo by ${image.user} on Pixabay',
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(icon: Icons.visibility_outlined, value: formatCount(image.views), label: 'Views'),
              _Stat(icon: Icons.thumb_up_outlined, value: formatCount(image.likes), label: 'Likes'),
              _Stat(icon: Icons.download_outlined, value: formatCount(image.downloads), label: 'Downloads'),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final tag in image.tagList) Chip(label: Text(tag))],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isDownloading ? null : _download,
                  icon: progress == null
                      ? const Icon(Icons.download)
                      : SizedBox(
                          width: 18,
                          height: 18,
                         
                          child: CircularProgressIndicator(value: progress, strokeWidth: 2),
                        ),
                  label: Text(
                    progress == null ? 'Download' : '${(progress * 100).round()}%',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.outlined(
                tooltip: 'Share',
                icon: const Icon(Icons.share_outlined),
                onPressed: _share,
              ),
              const SizedBox(width: 8),
              FavoriteButton(image: image),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}