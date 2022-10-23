import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../music_player.dart';

class PlaylistSongScreen extends StatelessWidget {
  final Playlist playlist;

  const PlaylistSongScreen({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, state) {
        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            title: Text(playlist.name),
            actions: [
              IconButton(
                onPressed: () => context.read<PlaylistCubit>().deletePlaylist(playlist).then((value) => Navigator.pop(context)),
                icon: const Icon(PhosphorIcons.trash),
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateEditPlaylist(playlist: playlist)),
                ),
                icon: const Icon(PhosphorIcons.pen),
              ),
            ],
          ),
          body: ResizableScrollView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                      child: RoundedButton.semitransparentButton(
                        onPress: () => context.read<PlayerBloc>()
                          ..add(PlayerNewSong(songs: playlist.songs, currentIndex: 0))
                          ..add(PlayerShuffle(false))
                          ..add(PlayerPlayPause(true)),
                        color: AppColor.green,
                        icon: PhosphorIcons.musicNote,
                        title: 'Play All',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                      child: RoundedButton.semitransparentButton(
                        onPress: () => context.read<PlayerBloc>()
                          ..add(PlayerNewSong(songs: playlist.songs, currentIndex: Random().nextInt(playlist.songs.length)))
                          ..add(PlayerShuffle(true))
                          ..add(PlayerPlayPause(true)),
                        color: AppColor.purple,
                        icon: PhosphorIcons.shuffle,
                        title: 'Shuffle All',
                      ),
                    ),
                  ),
                ],
              ),
              ...playlist.songs.map((item) => musicTile(
                    song: item,
                    onTap: () => context.read<PlayerBloc>()
                    ..add(PlayerNewSong(songs: playlist.songs, currentIndex: playlist.songs.indexOf(item)))
                    ..add(PlayerPlayPause(true)),
                  )),
              const SizedBox(height: 120)
            ],
          ),
          bottomNavigationBar: PlayerTile(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              clipBehavior: Clip.antiAlias,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Constant.radiusMedium),
                ),
              ),
              builder: (context) => const PlayerScreen(),
            ),
          ),
        );
      },
    );
  }

  Widget musicTile({required Song song, required void Function() onTap}) => ListTile(
        onTap: onTap,
        leading: SongCoverImage(song: song),
        title: Text(song.title, maxLines: 1),
        subtitle: Text(song.artist, maxLines: 1),
      );
}
