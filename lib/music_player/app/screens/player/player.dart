import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../music_player.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  static void open(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Constant.radiusMedium)),
        ),
        builder: (context) => const PlayerScreen(),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final player = context.read<PlayerBloc>();

    return BlocBuilder<PlayerBloc, MusicPlayerState>(
      builder: (context, state) {
        // The queue can be emptied from the queue sheet while this is open.
        if (state.currentIndex == null || state.songs.length <= state.currentIndex!) {
          return const SizedBox.shrink();
        }
        var song = state.songs[state.currentIndex!];
        Color dim(bool active) => active ? scheme.onSurface : scheme.onSurfaceVariant.withValues(alpha: 0.6);

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Constant.paddingLarge),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(PhosphorIcons.caretDown),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Queue',
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          clipBehavior: Clip.antiAlias,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(Constant.radiusMedium)),
                          ),
                          builder: (context) => const QueueList(),
                        ),
                        icon: const Icon(PhosphorIcons.queue),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                AspectRatio(
                  aspectRatio: 1,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: SongCoverImage(
                      key: Key(song.filePath),
                      song: song,
                      height: double.infinity,
                      width: double.infinity,
                      borderRadius: Constant.radiusMedium,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    FavoriteIconButton(
                      key: Key(song.filePath),
                      size: 24,
                      isActive: song.isFavorite,
                      onPressed: (value) => context.read<MusicCubit>().markFavorite(song),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SeekBar(
                  songDuration: player.songDuration,
                  songPosition: player.songPosition,
                  onSeek: player.setPosition,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        tooltip: 'Shuffle',
                        onPressed: () => player.add(PlayerShuffle(!state.shuffle)),
                        color: dim(state.shuffle),
                        icon: const Icon(PhosphorIcons.shuffle),
                      ),
                      IconButton(
                        tooltip: 'Previous',
                        iconSize: 28,
                        onPressed: () => player
                          ..add(PlayerNextPrevious(false))
                          ..add(PlayerPlayPause(true)),
                        icon: const Icon(PhosphorIcons.skipBackFill),
                      ),
                      PlayPauseButton(
                        mini: false,
                        state: state.playing,
                        onPlayPauseTap: (value) => player.add(PlayerPlayPause(value)),
                      ),
                      IconButton(
                        tooltip: 'Next',
                        iconSize: 28,
                        onPressed: () => player
                          ..add(PlayerNextPrevious(true))
                          ..add(PlayerPlayPause(true)),
                        icon: const Icon(PhosphorIcons.skipForwardFill),
                      ),
                      IconButton(
                        tooltip: 'Repeat',
                        onPressed: () {
                          LoopMode mode = switch (state.loopMode) {
                            LoopMode.off => LoopMode.all,
                            LoopMode.all => LoopMode.one,
                            LoopMode.one => LoopMode.off,
                          };
                          player.add(PlayerLoopMode(mode));
                        },
                        color: dim(state.loopMode != LoopMode.off),
                        icon: Icon(state.loopMode == LoopMode.one ? PhosphorIcons.repeatOnce : PhosphorIcons.repeat),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
