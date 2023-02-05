// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../../music_player.dart';

part 'player_event.dart';

part 'player_state.dart';

class PlayerBloc extends HydratedBloc<PlayerEvent, MusicPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late StreamSubscription _songIndexStream, _playPauseStream;

  PlayerBloc() : super(MusicPlayerState.initial()) {
    _songIndexStream = _audioPlayer.currentIndexStream.listen((index) {
      //TODO: Update Widget From Here
      emit(state.copyWith(currentIndex: index));
    });

    _playPauseStream = _audioPlayer.playingStream.listen((playing) {
      //TODO: Update Widget From Here
      emit(state.copyWith(playing: playing));
    });

    on<PlayerPlayPause>((event, emit) {
      if (event.play) {
        _audioPlayer.play();
      } else {
        _audioPlayer.pause();
      }
      // emit(state.copyWith(playing: event.play));
    });

    on<PlayerNextPrevious>((event, emit) {
      if (event.next) {
        _audioPlayer.seekToNext();
      } else {
        _audioPlayer.seekToPrevious();
      }
    });

    on<PlayerShuffle>((event, emit) async {
      await _audioPlayer.setShuffleModeEnabled(event.shuffle);
      emit(state.copyWith(shuffle: event.shuffle));
    });

    on<PlayerLoopMode>((event, emit) async {
      await _audioPlayer.setLoopMode(event.loopMode);
      emit(state.copyWith(loopMode: event.loopMode));
    });

    on<PlayerNewSong>((event, emit) async {
      if (event.songs.isNotEmpty) {
        if (state.songs != event.songs) {
          var playlist = ConcatenatingAudioSource(
            useLazyPreparation: true,
            children: List.from(event.songs).map((item) => audioSourceFromSong(item)).toList(),
          );
          await _audioPlayer.setAudioSource(playlist, initialIndex: event.currentIndex);
        } else {
          await _audioPlayer.seek(Duration.zero, index: event.currentIndex);
        }
      }

      emit(state.copyWith(currentIndex: event.currentIndex, songs: List.from(event.songs)));
    });

    on<PlayerRemoveSong>((event, emit) async {
      if (_audioPlayer.audioSource != null) {
        if (_audioPlayer.audioSource is ConcatenatingAudioSource) {
          await (_audioPlayer.audioSource as ConcatenatingAudioSource).removeAt(event.index);
          List<Song> songs = List.from(state.songs)..removeAt(event.index);
          emit(state.copyWith(songs: songs, currentIndex: _audioPlayer.currentIndex));
        }
      }
    });
  }

  Stream<Duration?> get songDuration => _audioPlayer.durationStream;

  Stream<Duration> get songPosition => _audioPlayer.positionStream;

  void setPosition(int position) => _audioPlayer.seek(Duration(seconds: position));

  AudioSource audioSourceFromSong(Song song) => AudioSource.uri(
        Uri.file(song.filePath),
        tag: MediaItem(
          id: song.filePath,
          title: song.title,
          album: song.album,
          artist: song.artist,
          artUri: song.albumArtUrl != null ? Uri.file(song.albumArtUrl!) : null,
        ),
      );

  @override
  Future<void> close() {
    _songIndexStream.cancel();
    _playPauseStream.cancel();
    _audioPlayer.dispose();
    return super.close();
  }

  @override
  MusicPlayerState? fromJson(Map<String, dynamic> json) {
    try {
      var state = MusicPlayerState.fromJson(json);
      if (state.currentIndex != null) {
        _audioPlayer.setShuffleModeEnabled(state.shuffle);
        _audioPlayer.setLoopMode(state.loopMode);
        _audioPlayer.setAudioSource(
          ConcatenatingAudioSource(
            useLazyPreparation: true,
            children: List.from(state.songs).map((item) => audioSourceFromSong(item)).toList(),
          ),
          initialIndex: state.currentIndex,
        );
      }
      return state;
    } catch (e) {
      Logger.error('PlayerBloc.fromJson.error: $e', e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(MusicPlayerState state) => state.toJson();
}

extension LoopModeX on LoopMode {
  static LoopMode fromName(String name) {
    switch (name) {
      case 'off':
        return LoopMode.off;
      case 'all':
        return LoopMode.all;
      case 'one':
        return LoopMode.one;
      default:
        return LoopMode.all;
    }
  }
}
