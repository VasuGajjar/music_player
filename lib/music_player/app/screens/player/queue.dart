import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../music_player.dart';

class QueueList extends StatelessWidget {
  const QueueList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlayerBloc, MusicPlayerState>(
      listener: (context, state) {},
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: state.songs.length,
          itemBuilder: (context, index) {
            Song song = state.songs[index];
            return ListTile(
              onTap: () => context.read<PlayerBloc>()
                ..add(PlayerNewSong(songs: state.songs, currentIndex: index))
                ..add(PlayerPlayPause(true)),
              leading: SongCoverImage(song: song),
              title: Text(song.title, maxLines: 1),
              subtitle: Text(song.artist, maxLines: 1),
              trailing: IconButton(
                onPressed: () => context.read<PlayerBloc>().add(PlayerRemoveSong(index)),
                icon: const Icon(PhosphorIcons.minusCircle),
              ),
              tileColor: index == state.currentIndex ? AppColor.offWhite : AppColor.white,
            );
          },
        );
      },
    );
  }
}
