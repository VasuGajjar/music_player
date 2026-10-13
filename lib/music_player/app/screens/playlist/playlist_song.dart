import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../music_player.dart';

class PlaylistSongScreen extends StatelessWidget {
  final Playlist playlist;

  const PlaylistSongScreen({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, state) {
        final songs = playlist.songs;
        final player = context.read<PlayerBloc>();

        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            actions: [
              IconButton(
                tooltip: 'Edit',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateEditPlaylist(playlist: playlist)),
                ),
                icon: const Icon(PhosphorIcons.pencilSimple),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () => context.read<PlaylistCubit>().deletePlaylist(playlist).then((value) {
                  if (context.mounted) Navigator.pop(context);
                }),
                icon: const Icon(PhosphorIcons.trash),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 160),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Row(
                  children: [
                    PlaylistCoverImage(playlist: playlist, height: 96, width: 96, borderRadius: Constant.radiusSmall),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.4),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${songs.length} tracks',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: songs.isEmpty
                            ? null
                            : () => player
                              ..add(PlayerNewSong(songs: songs, currentIndex: 0))
                              ..add(PlayerShuffle(false))
                              ..add(PlayerPlayPause(true)),
                        icon: const Icon(PhosphorIcons.playFill, size: 18),
                        label: const Text('Play'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: songs.isEmpty
                            ? null
                            : () => player
                              ..add(PlayerNewSong(songs: songs, currentIndex: Random().nextInt(songs.length)))
                              ..add(PlayerShuffle(true))
                              ..add(PlayerPlayPause(true)),
                        icon: const Icon(PhosphorIcons.shuffle, size: 18),
                        label: const Text('Shuffle'),
                      ),
                    ),
                  ],
                ),
              ),
              for (final (index, song) in songs.indexed)
                MusicTile(
                  song: song,
                  onTap: () => player
                    ..add(PlayerNewSong(songs: songs, currentIndex: index))
                    ..add(PlayerPlayPause(true)),
                ),
            ],
          ),
          bottomNavigationBar: const PlayerTile(),
        );
      },
    );
  }
}
