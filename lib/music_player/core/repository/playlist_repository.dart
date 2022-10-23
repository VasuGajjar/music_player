import 'dart:async';

import 'package:hive/hive.dart';

import '../../music_player.dart';

class PlaylistRepository {
  final Box<Playlist> playlistBox = Hive.box<Playlist>(Constant.playlistBox);

  Future<void> createPlaylist(String name, [List<Song>? songs]) => playlistBox.add(
        Playlist(
          name: name,
          songs: HiveList(Hive.box<Song>(Constant.musicBox), objects: songs),
        ),
      );

  Future<void> delete(Playlist playlist) => playlist.delete();

  Stream<List<Playlist>> get allPlaylists async* {
    yield playlistBox.values.toList();
    yield* playlistBox.watch().map((event) => playlistBox.values.toList());
  }

  void removeFromPlaylist(Playlist playlist, int index) => playlist
    ..songs.removeAt(index)
    ..save();

  void updatePlaylist(Playlist playlist, List<Song> songs) => playlist
    ..songs = HiveList(Hive.box<Song>(Constant.musicBox), objects: songs)
    ..save();

  void changeName(Playlist playlist, String name) => playlist
    ..name = name
    ..save();
}
