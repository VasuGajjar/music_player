import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';

import '../../music_player.dart';

/// Publishes the [AudioPlayer] to the system media session.
///
/// Android draws the media notification, lock screen / quick settings player and OEM
/// status-bar capsules (e.g. OnePlus Fluid Cloud) itself from this session, so all we
/// control there is the metadata, artwork and which buttons are offered.
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  static const _favorite = 'favorite', _shuffle = 'shuffle';
  static const _liveUpdate = MethodChannel('com.vasugajjar.music_player/live_update');

  final player = AudioPlayer();
  final _songs = Hive.box<Song>(Constant.musicBox);
  String? _liveUpdateKey;

  AudioPlayerHandler() {
    player.playbackEventStream.listen((_) => _broadcast());
    player.playingStream.listen((_) => _broadcast());
    player.shuffleModeEnabledStream.listen((_) => _broadcast());
    player.loopModeStream.listen((_) => _broadcast());
    player.sequenceStateStream.listen((_) => _updateMediaItem());
    player.durationStream.listen((_) => _updateMediaItem());
    // Favorites also change in-app; keep the notification heart in sync.
    _songs.watch().listen((_) => _broadcast());
  }

  void _updateMediaItem() {
    final item = player.sequenceState.currentSource?.tag as MediaItem?;
    if (item == null) return;
    // The system seek bar only shows once the item carries a duration.
    mediaItem.add(item.copyWith(duration: player.duration));
    _broadcast();
  }

  Song? get _currentSong {
    final id = mediaItem.value?.id;
    return id == null ? null : _songs.get(id);
  }

  void _broadcast() {
    final playing = player.playing;
    final favorite = _currentSong?.isFavorite ?? false;
    final shuffle = player.shuffleModeEnabled;

    playbackState.add(playbackState.value.copyWith(
      // Android 13+ shows play/pause, previous, next plus up to two custom actions.
      controls: [
        MediaControl.custom(
          androidIcon: favorite ? 'drawable/ic_favorite' : 'drawable/ic_favorite_border',
          label: favorite ? 'Remove from favorites' : 'Add to favorites',
          name: _favorite,
        ),
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.custom(
          androidIcon: shuffle ? 'drawable/ic_shuffle_on' : 'drawable/ic_shuffle_off',
          label: shuffle ? 'Shuffle off' : 'Shuffle on',
          name: _shuffle,
        ),
      ],
      systemActions: const {MediaAction.seek, MediaAction.seekForward, MediaAction.seekBackward},
      androidCompactActionIndices: const [1, 2, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: player.currentIndex,
      shuffleMode: shuffle ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
      repeatMode: const {
        LoopMode.off: AudioServiceRepeatMode.none,
        LoopMode.one: AudioServiceRepeatMode.one,
        LoopMode.all: AudioServiceRepeatMode.all,
      }[player.loopMode]!,
    ));
    _syncLiveUpdate();
  }

  /// Mirrors playback into an Android 16 Live Update: the status-bar chip that OEM island
  /// UIs (OnePlus Fluid Cloud) build on. A no-op where the OS doesn't support it.
  void _syncLiveUpdate() {
    final item = mediaItem.value;
    final active = item != null && player.processingState != ProcessingState.idle;
    final key = active ? '${item.id}|${player.playing}|${player.position.inSeconds}|${player.duration?.inSeconds}' : null;
    if (key == _liveUpdateKey) return;
    _liveUpdateKey = key;

    if (!active) {
      _liveUpdate.invokeMethod('cancel').ignore();
      return;
    }
    _liveUpdate.invokeMethod('update', {
      'title': item.title,
      'artist': item.artist ?? '',
      'art': item.artUri?.toFilePath(),
      'playing': player.playing,
      'position': player.position.inMilliseconds,
      'duration': player.duration?.inMilliseconds,
    }).ignore();
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() => player.stop();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() => player.seekToNext();

  @override
  Future<void> skipToPrevious() => player.seekToPrevious();

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) =>
      player.setShuffleModeEnabled(shuffleMode != AudioServiceShuffleMode.none);

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) => player.setLoopMode(switch (repeatMode) {
        AudioServiceRepeatMode.none => LoopMode.off,
        AudioServiceRepeatMode.one => LoopMode.one,
        AudioServiceRepeatMode.all || AudioServiceRepeatMode.group => LoopMode.all,
      });

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case _favorite:
        final song = _currentSong;
        if (song != null) await MusicRepository().markFavorite(song);
      case _shuffle:
        await player.setShuffleModeEnabled(!player.shuffleModeEnabled);
    }
  }
}
