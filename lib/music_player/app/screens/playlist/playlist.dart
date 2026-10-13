import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../music_player.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, state) {
        if (state.status.isFailure) {
          return EmptyState(icon: PhosphorIcons.warning, text: state.error);
        }

        // The playlist stream only emits after a change, so "loading" also means "none yet".
        if (state.status.isLoading || (state.status.isSuccess && state.playlists.isEmpty)) {
          return EmptyState(
            icon: PhosphorIcons.playlist,
            text: 'No playlists yet',
            action: TextButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateEditPlaylist())),
              icon: const Icon(PhosphorIcons.plus, size: 18),
              label: const Text('Create one'),
            ),
          );
        }

        if (!state.status.isSuccess) return const SizedBox.shrink();

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: Constant.paddingMedium,
            mainAxisSpacing: Constant.paddingLarge,
            crossAxisCount: 2,
            childAspectRatio: 0.78,
          ),
          itemCount: state.playlists.length,
          padding: const EdgeInsets.fromLTRB(Constant.paddingMedium, Constant.paddingMedium, Constant.paddingMedium, 160),
          itemBuilder: (BuildContext context, int index) => playlistTile(context, state.playlists[index]),
        );
      },
    );
  }
}

Widget playlistTile(BuildContext context, Playlist playlist) => GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlaylistSongScreen(playlist: playlist)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PlaylistCoverImage(playlist: playlist, width: double.infinity, height: double.infinity),
          ),
          const SizedBox(height: 8),
          Text(playlist.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            '${playlist.songs.length} tracks',
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
