import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../music_player.dart';

class Search extends SearchDelegate<Song?> {
  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(PhosphorIcons.x),
          onPressed: () => query = '',
        )
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(PhosphorIcons.arrowLeft),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Song> songs = context.read<MusicCubit>().state.songs.where((item) => item.title.toLowerCase().contains(query.toLowerCase()) || item.album.toLowerCase().contains(query.toLowerCase()) || item.artist.toLowerCase().contains(query.toLowerCase())).toList();

    if (query.trim().isEmpty) {
      return const Center(
        child: LottieWithText(
          animation: Assets.searchAnimation,
          text: 'Type to Search',
        ),
      );
    }

    return ListView.builder(
      itemCount: songs.length,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (context, index) => ListTile(
        onTap: () => close(context, songs[index]),
        leading: SongCoverImage(song: songs[index]),
        title: Text(songs[index].title, maxLines: 1),
        subtitle: Text(songs[index].artist, maxLines: 1),
      ),
    );
  }
}
