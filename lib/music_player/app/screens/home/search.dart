import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../music_player.dart';

class Search extends SearchDelegate<Song?> {
  Search() : super(searchFieldLabel: 'Search songs, artists, albums');

  // Keep the app's own app bar styling instead of SearchDelegate's grey default.
  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(PhosphorIcons.x),
            onPressed: () => query = '',
          ),
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
    if (query.trim().isEmpty) {
      return const EmptyState(icon: PhosphorIcons.magnifyingGlass, text: 'Type to search');
    }

    final q = query.toLowerCase();
    List<Song> songs = context
        .read<MusicCubit>()
        .state
        .songs
        .where((item) => item.title.toLowerCase().contains(q) || item.album.toLowerCase().contains(q) || item.artist.toLowerCase().contains(q))
        .toList();

    if (songs.isEmpty) {
      return EmptyState(
        icon: PhosphorIcons.musicNote,
        text: 'No matches in your library',
        action: TextButton.icon(
          onPressed: () => OnlineScreen.open(context, query),
          icon: const Icon(PhosphorIcons.youtubeLogo, size: 18),
          label: const Text('Search YouTube'),
        ),
      );
    }

    return ListView.builder(
      itemCount: songs.length + 1,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) => index == songs.length
          ? ListTile(
              onTap: () => OnlineScreen.open(context, query),
              leading: const SizedBox.square(dimension: 48, child: Icon(PhosphorIcons.youtubeLogo)),
              title: Text('Search "${query.trim()}" on YouTube', maxLines: 1, overflow: TextOverflow.ellipsis),
            )
          : MusicTile(
              song: songs[index],
              onTap: () => close(context, songs[index]),
              trailing: const SizedBox.shrink(),
            ),
    );
  }
}
