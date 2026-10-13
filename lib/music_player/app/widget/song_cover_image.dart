import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../music_player.dart';

class SongCoverImage extends StatelessWidget {
  final Song song;
  final double height, width;
  final double borderRadius;

  const SongCoverImage({
    Key? key,
    required this.song,
    this.height = 48,
    this.width = 48,
    this.borderRadius = Constant.radiusSmall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Center(
      child: Icon(
        PhosphorIcons.musicNote,
        color: scheme.onSurfaceVariant,
        size: (height.isFinite ? height : 48) / 2.5,
      ),
    );

    return Container(
      height: height,
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(borderRadius)),
      child: song.albumArtUrl == null
          ? placeholder
          : LayoutBuilder(builder: (context, box) {
              // Decode at the size shown, not the full embedded art: full-size decodes in
              // every list tile overflow the image cache and make scrolling stutter.
              final cacheWidth = box.biggest.isFinite ? (box.biggest.longestSide * MediaQuery.devicePixelRatioOf(context)).round() : null;
              final art = song.albumArtUrl!;
              // Streamed songs carry their YouTube thumbnail url.
              return art.startsWith('http')
                  ? Image.network(art, fit: BoxFit.cover, cacheWidth: cacheWidth, gaplessPlayback: true, errorBuilder: (context, error, stackTrace) => placeholder)
                  : Image.file(File(art), fit: BoxFit.cover, cacheWidth: cacheWidth, gaplessPlayback: true, errorBuilder: (context, error, stackTrace) => placeholder);
            }),
    );
  }
}
