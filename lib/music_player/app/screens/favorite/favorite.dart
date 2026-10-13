import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../music_player.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key? key}) : super(key: key);

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
          return EmptyState(icon: PhosphorIcons.warning, text: state.error);
        } else if (state.status.isSuccess) {
          var favoriteSongs = state.songs.where((element) => element.isFavorite).toList();
          if (favoriteSongs.isEmpty) {
            return const EmptyState(icon: PhosphorIcons.heart, text: 'No favorites yet');
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 160),
            itemCount: favoriteSongs.length,
            itemBuilder: (context, index) => MusicTile(
              song: favoriteSongs[index],
              onTap: () => context.read<PlayerBloc>()
                ..add(PlayerNewSong(songs: favoriteSongs, currentIndex: index))
                ..add(PlayerPlayPause(true)),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
