import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:storage_helper/storage_helper.dart';

import '../../../music_player.dart';

part 'music_state.dart';

class MusicCubit extends Cubit<MusicState> {
  MusicCubit() : super(MusicState.loading()) {
    _songsStreamController = _musicRepo.allSongs.listen(
      (songs) => emit(MusicState.success(songs)),
      onError: (err) => emit(MusicState.failure(err.toString())),
    );
  }

  final _musicRepo = MusicRepository();
  late StreamSubscription<List<Song>> _songsStreamController;

  Future<void> getSongs() async {
    try {
      emit(MusicState.loading());
      await _musicRepo.fetchSongsFromStorage();
      emit(MusicState.success(_musicRepo.musicBox.values.toList()));
    } on StorageHelperException catch (e) {
      emit(MusicState.failure(e.message));
    } catch (_) {
      emit(MusicState.failure());
    }
  }

  Future<void> markFavorite(Song song) => _musicRepo.markFavorite(song);

  Future<File?> getCoverImage(Song song) => _musicRepo.getCoverImage(song);

  @override
  Future<void> close() {
    _songsStreamController.cancel();
    return super.close();
  }
}
