// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 0;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song(
      title: fields[0] as String,
      artist: fields[1] as String,
      album: fields[2] as String,
      albumArtUrl: fields[3] as String?,
      filePath: fields[4] as String,
      isFavorite: fields[5] as bool,
      dominantColor: fields[6] as int,
      textColor: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.artist)
      ..writeByte(2)
      ..write(obj.album)
      ..writeByte(3)
      ..write(obj.albumArtUrl)
      ..writeByte(4)
      ..write(obj.filePath)
      ..writeByte(5)
      ..write(obj.isFavorite)
      ..writeByte(6)
      ..write(obj.dominantColor)
      ..writeByte(7)
      ..write(obj.textColor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Song _$SongFromJson(Map<String, dynamic> json) => Song(
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String,
      albumArtUrl: json['albumArtUrl'] as String?,
      filePath: json['filePath'] as String,
      isFavorite: json['isFavorite'] as bool,
      dominantColor: json['dominantColor'] as int,
      textColor: json['textColor'] as int,
    );

Map<String, dynamic> _$SongToJson(Song instance) => <String, dynamic>{
      'title': instance.title,
      'artist': instance.artist,
      'album': instance.album,
      'albumArtUrl': instance.albumArtUrl,
      'filePath': instance.filePath,
      'isFavorite': instance.isFavorite,
      'dominantColor': instance.dominantColor,
      'textColor': instance.textColor,
    };
