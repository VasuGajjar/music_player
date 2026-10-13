import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../music_player.dart';

class MusicTile extends StatelessWidget {
  final Song song;
  final void Function()? onTap;
  final Widget? trailing;
  final bool selected;

  const MusicTile({
    Key? key,
    required this.song,
    this.onTap,
    this.trailing,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      selected: selected,
      leading: SongCoverImage(song: song),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: trailing ??
          FavoriteIconButton(
            key: Key(song.title),
            isActive: song.isFavorite,
            onPressed: (_) => context.read<MusicCubit>().markFavorite(song),
          ),
    );
  }
}
