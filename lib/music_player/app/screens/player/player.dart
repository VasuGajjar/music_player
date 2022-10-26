import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../music_player.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  GlobalKey<SeekBarState> seekbarKey = GlobalKey<SeekBarState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlayerBloc, MusicPlayerState>(
      listener: (context, state) {
        seekbarKey.currentState?.changeColor(Color(state.songs[state.currentIndex!].textColor));
      },
      builder: (context, state) {
        var song = state.songs[state.currentIndex!];
        return Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: backgroundImage(song),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: backgroundBlur(song),
            ),
            backgroundBlur(song),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 48, left: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(PhosphorIcons.caretDown),
                      color: Color(song.textColor).withOpacity(0.7),
                    ),
                  ),
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: SongCoverImage(
                    key: Key(song.title),
                    song: song,
                    height: MediaQuery.of(context).size.width * 0.65,
                    width: MediaQuery.of(context).size.width * 0.65,
                  ),
                ),
                const Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Color(song.textColor).withOpacity(0.07),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(Constant.radiusLarge),
                      )),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        textColor: Color(song.textColor).withOpacity(0.7),
                        title: Center(child: Text(song.title, maxLines: 1)),
                        subtitle: Center(child: Text(song.artist, maxLines: 1)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FavoriteIconButton(
                              key: Key(song.title),
                              color: Color(song.textColor),
                              isActive: song.isFavorite,
                              onPressed: (value) => context.read<MusicCubit>().markFavorite(song),
                            ),
                            IconButton(
                              onPressed: () => context.read<PlayerBloc>().add(PlayerShuffle(!state.shuffle)),
                              color: Color(song.textColor).withOpacity(state.shuffle ? 0.7 : 0.4),
                              icon: const Icon(PhosphorIcons.shuffleFill),
                            ),
                            IconButton(
                              onPressed: () {
                                LoopMode mode = state.loopMode == LoopMode.off
                                    ? LoopMode.all
                                    : state.loopMode == LoopMode.all
                                        ? LoopMode.one
                                        : LoopMode.off;
                                context.read<PlayerBloc>().add(PlayerLoopMode(mode));
                              },
                              color: Color(song.textColor).withOpacity(state.loopMode == LoopMode.off ? 0.4 : 0.7),
                              icon: Icon(state.loopMode == LoopMode.one ? PhosphorIcons.repeatOnce : PhosphorIcons.repeat),
                            ),
                            IconButton(
                              onPressed: () => showModalBottomSheet(
                                context: context,
                                backgroundColor: AppColor.white,
                                clipBehavior: Clip.antiAlias,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(Constant.radiusMedium),
                                  ),
                                ),
                                builder: (context) => const QueueList(),
                              ),
                              color: Color(song.textColor).withOpacity(0.7),
                              icon: const Icon(PhosphorIcons.queueFill),
                            ),
                          ],
                        ),
                      ),
                      seekBar(color: Color(song.textColor)),
                      Padding(
                        padding: const EdgeInsets.all(12).copyWith(bottom: 36),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: () => context.read<PlayerBloc>()
                                ..add(PlayerNextPrevious(false))
                                ..add(PlayerPlayPause(true)),
                              color: Color(song.textColor).withOpacity(0.7),
                              icon: const Icon(PhosphorIcons.skipBackFill),
                            ),
                            PlayPauseButton(
                              mini: false,
                              state: state.playing,
                              color: Color(song.textColor).withOpacity(0.7),
                              iconColor: Color(song.dominantColor).withOpacity(0.7),
                              onPlayPauseTap: (value) => context.read<PlayerBloc>().add(PlayerPlayPause(value)),
                            ),
                            IconButton(
                              onPressed: () => context.read<PlayerBloc>()
                                ..add(PlayerNextPrevious(true))
                                ..add(PlayerPlayPause(true)),
                              color: Color(song.textColor).withOpacity(0.7),
                              icon: const Icon(PhosphorIcons.skipForwardFill),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget backgroundImage(Song? song) => SongCoverImage(
        key: Key(song?.title ?? ''),
        song: song ?? Song.empty(),
        borderRadius: 0,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      );

  Widget backgroundBlur(Song song) => BackdropFilter(
        key: Key(song.title),
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: Color(song.dominantColor).withOpacity(0.2),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
      );

  Widget seekBar({Color? color}) => SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SeekBar(
          key: seekbarKey,
          songDuration: context.read<PlayerBloc>().songDuration,
          songPosition: context.read<PlayerBloc>().songPosition,
          onSeek: context.read<PlayerBloc>().setPosition,
          initialColor: color ?? AppColor.offWhite,
        ),
      );
}
