part of 'player_bloc.dart';

class MusicPlayerState extends Equatable {
  final bool shuffle;
  final LoopMode loopMode;
  final bool playing;
  final int? currentIndex;
  final List<Song> songs;

  const MusicPlayerState._({
    this.shuffle = false,
    this.loopMode = LoopMode.all,
    this.playing = false,
    this.songs = const [],
    this.currentIndex,
  });

  factory MusicPlayerState.initial() => const MusicPlayerState._();

  MusicPlayerState copyWith({
    bool? shuffle,
    LoopMode? loopMode,
    bool? playing,
    int? currentIndex,
    List<Song>? songs,
  }) =>
      MusicPlayerState._(
        shuffle: shuffle ?? this.shuffle,
        loopMode: loopMode ?? this.loopMode,
        playing: playing ?? this.playing,
        songs: songs ?? this.songs,
        currentIndex: currentIndex ?? this.currentIndex,
      );

  @override
  List<Object?> get props => [shuffle, loopMode, playing, songs, currentIndex];

  @override
  bool? get stringify => true;

  factory MusicPlayerState.fromJson(Map<String, dynamic> json) => MusicPlayerState._(
        shuffle: json['shuffle'] ?? false,
        loopMode: LoopModeX.fromName(json['loop'] ?? ''),
        playing: false,
        currentIndex: json['currentIndex'],
        songs: (json['songs'] as List).map((e) => Song.fromJson(e)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'shuffle': shuffle,
        'loop': loopMode.name,
        'playing': false,
        'currentIndex': currentIndex,
        'songs': songs.map((e) => e.toJson()).toList(),
      };
}
