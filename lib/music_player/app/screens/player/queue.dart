import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../music_player.dart';

class QueueList extends StatelessWidget {
  const QueueList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, MusicPlayerState>(
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: state.songs.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text('Up next', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              );
            }
            index--;
            return MusicTile(
              song: state.songs[index],
              selected: index == state.currentIndex,
              onTap: () => context.read<PlayerBloc>()
                ..add(PlayerNewSong(songs: state.songs, currentIndex: index))
                ..add(PlayerPlayPause(true)),
              trailing: IconButton(
                tooltip: 'Remove',
                onPressed: () => context.read<PlayerBloc>().add(PlayerRemoveSong(index)),
                icon: const Icon(PhosphorIcons.minusCircle),
              ),
            );
          },
        );
      },
    );
  }
}
