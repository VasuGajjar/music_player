part of 'music_cubit.dart';

enum MusicStatus { loading, success, failure }

class MusicState {
  final MusicStatus status;
  final String error;
  final List<Song> songs;

  const MusicState._({
    this.status = MusicStatus.loading,
    this.error = '',
    this.songs = const [],
  });

  factory MusicState.loading() => const MusicState._();

  factory MusicState.success(List<Song> songs) => MusicState._(
        status: MusicStatus.success,
        songs: songs,
      );

  factory MusicState.failure([String? error]) => MusicState._(
        status: MusicStatus.failure,
        error: error ?? 'Something went wrong',
      );
}

extension MusicStatusX on MusicStatus {
  bool get isLoading => this == MusicStatus.loading;

  bool get isSuccess => this == MusicStatus.success;

  bool get isFailure => this == MusicStatus.failure;
}
