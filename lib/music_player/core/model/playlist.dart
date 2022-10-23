import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '../../music_player.dart';

part 'playlist.g.dart';

@HiveType(typeId: 1)
class Playlist with EquatableMixin, HiveObjectMixin {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<Song> songs;

  Playlist({
    required this.name,
    required this.songs,
  });

  @override
  List<Object> get props => [name, songs];
}