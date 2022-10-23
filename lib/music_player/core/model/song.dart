import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'song.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class Song with EquatableMixin, HiveObjectMixin {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String artist;

  @HiveField(2)
  final String album;

  @HiveField(3)
  String? albumArtUrl;

  @HiveField(4)
  final String filePath;

  @HiveField(5)
  bool isFavorite;

  Song({
    required this.title,
    required this.artist,
    required this.album,
    this.albumArtUrl,
    required this.filePath,
    required this.isFavorite,
  });

  factory Song.empty() => Song(
        title: '',
        artist: '',
        album: '',
        filePath: '',
        isFavorite: false,
      );

  @override
  List<Object> get props => [title, artist, album, albumArtUrl ?? '', filePath, isFavorite];

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

  Map<String, dynamic> toJson() => _$SongToJson(this);
}
