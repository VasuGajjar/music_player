import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../music_player.dart';

/// Mini player pinned to the bottom of a screen; tapping it opens [PlayerScreen].
class PlayerTile extends StatelessWidget {
  const PlayerTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<PlayerBloc, MusicPlayerState>(
      builder: (context, state) {
        if (state.currentIndex == null || state.songs.length <= (state.currentIndex ?? 0)) {
          return const SizedBox.shrink();
        }

        Song song = state.songs[state.currentIndex!];

        // Android 15+ forces edge-to-edge; keep the tile above the system nav bar.
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Material(
              color: scheme.surfaceContainerHigh,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constant.radiusMedium),
                side: BorderSide(color: scheme.outlineVariant),
              ),
              child: InkWell(
                onTap: () => PlayerScreen.open(context),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      SongCoverImage(song: song, height: 44, width: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      PlayPauseButton(
                        state: state.playing,
                        onPlayPauseTap: (value) => context.read<PlayerBloc>().add(PlayerPlayPause(value)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
