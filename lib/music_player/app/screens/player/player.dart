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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlayerBloc, MusicPlayerState>(
      listener: (context, state) {
        // if (state.playing) {
        //   playerButton.currentState?.play();
        // } else {
        //   playerButton.currentState?.pause();
        // }
      },
      builder: (context, state) {
        var song = state.songs[state.currentIndex!];
        return Stack(
          children: [
            backgroundImage(song),
            backgroundBlur(
              child: Column(
                children: [
                  songHeader(
                    title: song.title,
                    artist: song.artist,
                  ),
                  const Spacer(flex: 3),
                  SongCoverImage(
                    song: song,
                    height: MediaQuery.of(context).size.width * 0.85,
                    width: MediaQuery.of(context).size.width * 0.85,
                    borderRadius: Constant.radiusLarge,
                  ),
                  const Spacer(flex: 3),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FavoriteIconButton(
                          key: Key(song.title),
                          color: AppColor.offWhite,
                          isActive: song.isFavorite,
                          onPressed: (value) => context.read<MusicCubit>().markFavorite(song),
                        ),
                        IconButton(
                          onPressed: () => context.read<PlayerBloc>().add(PlayerShuffle(!state.shuffle)),
                          color: state.shuffle ? AppColor.skyBlue : AppColor.offWhite,
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
                          color: state.loopMode == LoopMode.off ? AppColor.offWhite : AppColor.skyBlue,
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
                          color: AppColor.offWhite,
                          icon: const Icon(PhosphorIcons.queueFill),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                  seekBar(),
                  const Spacer(flex: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () => context.read<PlayerBloc>()
                            ..add(PlayerNextPrevious(false))
                            ..add(PlayerPlayPause(true)),
                          color: AppColor.offWhite,
                          icon: const Icon(PhosphorIcons.skipBackFill),
                        ),
                        PlayPauseButton(
                          mini: false,
                          state: state.playing,
                          onPlayPauseTap: (value) => context.read<PlayerBloc>().add(PlayerPlayPause(value)),
                        ),
                        IconButton(
                          onPressed: () => context.read<PlayerBloc>()
                            ..add(PlayerNextPrevious(true))
                            ..add(PlayerPlayPause(true)),
                          color: AppColor.offWhite,
                          icon: const Icon(PhosphorIcons.skipForwardFill),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 5),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget backgroundImage(Song? song) => SongCoverImage(
        song: song ?? Song.empty(),
        borderRadius: 0,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      );

  Widget backgroundBlur({required Widget child}) => BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          color: AppColor.darkBlue.withOpacity(0.4),
          child: child,
        ),
      );

  Widget songHeader({String title = 'NA', String artist = 'NA'}) => Padding(
        padding: const EdgeInsets.only(top: 32),
        child: ListTile(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(PhosphorIcons.caretDown),
            color: AppColor.offWhite,
          ),
          textColor: AppColor.offWhite,
          title: Center(child: Text(title, maxLines: 1)),
          subtitle: Center(child: Text(artist, maxLines: 1)),
          trailing: const SizedBox(height: 48, width: 48),
          // trailing: IconButton(
          //   onPressed: () {},
          //   icon: const Icon(PhosphorIcons.dotsThreeVertical),
          //   color: AppColor.offWhite,
          // ),
        ),
      );

  Widget seekBar() => SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SeekBar(
          songDuration: context.read<PlayerBloc>().songDuration,
          positionStream: context.read<PlayerBloc>().position,
          onSeek: context.read<PlayerBloc>().setPosition,
        ),
        // child: StreamBuilder<int>(
        //   stream: context.read<PlayerBloc>().position,
        //   builder: (context, snapshot) => Slider(
        //     min: 0,
        //     max: context.read<PlayerBloc>().songDuration.toDouble(),
        //     value: snapshot.data?.toDouble() ?? 0,
        //     activeColor: AppColor.offWhite,
        //     inactiveColor: AppColor.offWhite.withOpacity(0.4),
        //     onChanged: (value) => context.read<PlayerBloc>().setPosition(value.toInt()),
        //     onChangeEnd: (value) => context.read<PlayerBloc>().setPosition(value.toInt()),
        //   ),
        // ),
      );
}
