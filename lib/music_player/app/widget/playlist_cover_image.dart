import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../music_player.dart';

class PlaylistCoverImage extends StatelessWidget {
  final Playlist playlist;
  final double height, width;
  final double borderRadius;

  const PlaylistCoverImage({
    Key? key,
    required this.playlist,
    this.height = 120,
    this.width = 120,
    this.borderRadius = Constant.radiusMedium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final songs = playlist.songs;

    Widget cover(Song song) => Expanded(child: SongCoverImage(song: song, borderRadius: 0, height: double.infinity, width: double.infinity));

    return Container(
      height: height,
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(borderRadius)),
      child: switch (songs.length) {
        0 => Center(child: Icon(PhosphorIcons.musicNotes, color: scheme.onSurfaceVariant, size: 32)),
        1 => Row(children: [cover(songs[0])]),
        2 || 3 => Row(children: [cover(songs[0]), cover(songs[1])]),
        _ => Column(children: [
            Expanded(child: Row(children: [cover(songs[0]), cover(songs[1])])),
            Expanded(child: Row(children: [cover(songs[2]), cover(songs[3])])),
          ]),
      },
    );
  }
}
