import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../music_player.dart';

class MusicPage extends StatelessWidget {
  const MusicPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicCubit, MusicState>(
      builder: (context, state) {
        if (state.status.isLoading) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: 8,
            itemBuilder: (context, index) => const ShimmerTile(),
          );
        } else if (state.status.isFailure) {
          final isPermission = state.error.toLowerCase().contains('permission');
          return EmptyState(
            icon: isPermission ? PhosphorIcons.lock : PhosphorIcons.warning,
            text: state.error,
            action: isPermission
                ? TextButton.icon(
                    onPressed: context.read<MusicCubit>().getSongs,
                    icon: const Icon(PhosphorIcons.arrowCounterClockwise, size: 18),
                    label: const Text('Retry'),
                  )
                : null,
          );
        } else if (state.status.isSuccess) {
          if (state.songs.isEmpty) {
            return EmptyState(
              icon: PhosphorIcons.musicNote,
              text: 'No songs found',
              action: TextButton.icon(
                onPressed: context.read<MusicCubit>().getSongs,
                icon: const Icon(PhosphorIcons.arrowCounterClockwise, size: 18),
                label: const Text('Refresh'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: context.read<MusicCubit>().getSongs,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 160),
              itemCount: state.songs.length,
              itemBuilder: (context, index) => MusicTile(
                song: state.songs[index],
                onTap: () => context.read<PlayerBloc>()
                  ..add(PlayerNewSong(songs: state.songs, currentIndex: index))
                  ..add(PlayerPlayPause(true)),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
