part of 'player_bloc.dart';

abstract class PlayerEvent {}

// class PlayerInitialize extends PlayerEvent {}

class PlayerPlayPause extends PlayerEvent {
  bool play;

  PlayerPlayPause(this.play);
}

class PlayerShuffle extends PlayerEvent {
  bool shuffle;

  PlayerShuffle(this.shuffle);
}

class PlayerLoopMode extends PlayerEvent {
  LoopMode loopMode;

  PlayerLoopMode(this.loopMode);
}

class PlayerNewSong extends PlayerEvent {
  int currentIndex;
  List<Song> songs;

  PlayerNewSong({
    required this.songs,
    required this.currentIndex,
  });
}

class PlayerRemoveSong extends PlayerEvent {
  int index;

  PlayerRemoveSong(this.index);
}

class PlayerNextPrevious extends PlayerEvent {
  bool next;

  PlayerNextPrevious(this.next);
}
