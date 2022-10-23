part of 'playlist_cubit.dart';

enum PlaylistStatus { loading, success, failure }

class PlaylistState extends Equatable {
  final PlaylistStatus status;
  final String error;
  final List<Playlist> playlists;

  const PlaylistState._({
    this.status = PlaylistStatus.loading,
    this.error = '',
    this.playlists = const [],
  });

  factory PlaylistState.loading() => const PlaylistState._();

  factory PlaylistState.success(List<Playlist> playlists) => PlaylistState._(
        status: PlaylistStatus.success,
        playlists: playlists,
      );

  factory PlaylistState.failure([String? error]) => PlaylistState._(
        status: PlaylistStatus.failure,
        error: error ?? 'Something went wrong',
      );

  @override
  List<Object> get props => [status, error, playlists];
}

extension PlaylistStatusX on PlaylistStatus {
  bool get isLoading => this == PlaylistStatus.loading;

  bool get isSuccess => this == PlaylistStatus.success;

  bool get isFailure => this == PlaylistStatus.failure;
}
