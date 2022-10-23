import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_player/music_player/music_player.dart';

part 'playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  PlaylistCubit() : super(PlaylistState.loading()) {
    _playlistStreamController = _playlistRepo.allPlaylists.listen(
      (playlists) => emit(PlaylistState.success(playlists)),
      onError: (err) => emit(PlaylistState.failure(err.toString())),
    );
  }

  final _playlistRepo = PlaylistRepository();
  late StreamSubscription<List<Playlist>> _playlistStreamController;

  Future<void> createPlaylist(String name, [List<Song>? songs]) => _playlistRepo.createPlaylist(name, songs);

  Future<void> deletePlaylist(Playlist playlist) => _playlistRepo.delete(playlist);

  void removeFromPlaylist(Playlist playlist, int index) => _playlistRepo.removeFromPlaylist(playlist, index);

  void updatePlaylist(Playlist playlist, List<Song> songs) {
    _playlistRepo.updatePlaylist(playlist, songs);
    emit(state);
  }

  void changeName(Playlist playlist, String name) {
    _playlistRepo.changeName(playlist, name);
    emit(state);
  }

  @override
  Future<void> close() {
    _playlistStreamController.cancel();
    return super.close();
  }
}
