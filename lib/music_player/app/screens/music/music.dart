import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../music_player.dart';

class MusicPage extends StatelessWidget {
  const MusicPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicCubit, MusicState>(
      builder: (context, state) {
        if (state.status.isLoading) {
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            itemCount: 8,
            itemBuilder: (context, index) => const ShimmerTile(),
          );
        } else if (state.status.isFailure) {
          if (state.error.toLowerCase().contains('permission')) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LottieWithText(
                  animation: Assets.accessDeniedAnimation,
                  text: state.error,
                ),
                const SizedBox(height: 8),
                RoundedButton.semitransparentButton(
                  onPress: context.read<MusicCubit>().getSongs,
                  icon: PhosphorIcons.arrowCounterClockwise,
                  title: 'Retry',
                ),
              ],
            );
          }
          return Center(
            child: LottieWithText(
              animation: Assets.errorAnimation,
              text: state.error,
            ),
          );
        } else if (state.status.isSuccess) {
          if (state.songs.isEmpty) {
            return const Center(
              child: LottieWithText(
                animation: Assets.noSongsAnimation,
                text: 'No songs found',
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 108),
              itemCount: state.songs.length,
              itemBuilder: (context, index) => MusicTile(
                song: state.songs[index],
                onTap: () => context.read<PlayerBloc>()
                  ..add(PlayerNewSong(songs: state.songs, currentIndex: index))
                  ..add(PlayerPlayPause(true)),
              ),
            );
          }
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
