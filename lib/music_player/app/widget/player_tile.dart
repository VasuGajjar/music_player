import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../music_player.dart';

class PlayerTile extends StatefulWidget {
  final void Function() onTap;

  const PlayerTile({Key? key, required this.onTap}) : super(key: key);

  @override
  State<PlayerTile> createState() => PlayerTileState();
}

class PlayerTileState extends State<PlayerTile> {

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
        if (state.currentIndex == null || state.songs.length <= (state.currentIndex ?? 0)) {
          return const SizedBox.shrink();
        }

        Song song = state.songs[state.currentIndex!];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap: widget.onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Constant.radiusLarge),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  decoration: BoxDecoration(color: AppColor.darkBlue.withOpacity(0.7)),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: SongCoverImage(song: song),
                    title: Text(song.title, maxLines: 1, style: const TextStyle(color: AppColor.offWhite)),
                    subtitle: Text(song.artist, maxLines: 1, style: const TextStyle(color: AppColor.offWhite)),
                    trailing: PlayPauseButton(
                      state: state.playing,
                      onPlayPauseTap: (value) => context.read<PlayerBloc>().add(PlayerPlayPause(value)),
                    ),
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
