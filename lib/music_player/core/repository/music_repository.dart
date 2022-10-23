import 'dart:async';
import 'dart:io';

import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:storage_helper/storage_helper.dart';

import '../../music_player.dart';

class MusicRepository {
  final Box<Song> musicBox = Hive.box<Song>(Constant.musicBox);

  Future<void> fetchSongsFromStorage() async {
    List<String> storageSongs = await StorageHelper.getAudioList();
    Logger.data('Songs: ${storageSongs.toString()}');
    List<String> datastoreSongs = musicBox.values.map((e) => e.filePath).toList();

    // Deleting songs from datastore which are not present in storage
    for (var song in datastoreSongs) {
      if (!storageSongs.contains(song)) {
        musicBox.delete(song);
      }
    }

    // Add songs to datastore which are not present in datastore
    for (var songPath in storageSongs) {
      if (!datastoreSongs.contains(songPath)) {
        var metadata = await MetadataRetriever.fromFile(File(songPath));
        String trackName = metadata.trackName ?? path.basename(songPath);
        String? coverImagePath = await StorageHelper.getAlbumCover(trackName, metadata.albumArt);
        var song = Song(
          title: trackName,
          artist: metadata.trackArtistNames?.join(' ,') ?? 'NA',
          album: metadata.albumName ?? 'NA',
          albumArtUrl: coverImagePath,
          filePath: songPath,
          isFavorite: false,
        );
        musicBox.put(songPath, song);
      }
    }
  }

  Future<File?> getCoverImage(Song song) async {
    if (song.albumArtUrl == null) return null;

    if (song == Song.empty()) return null;

    File coverImage = File(song.albumArtUrl!);
    if (await coverImage.exists()) {
      return coverImage;
    } else {
      var metadata = await MetadataRetriever.fromFile(File(song.filePath));
      String? coverImagePath = await StorageHelper.getAlbumCover(song.title, metadata.albumArt);
      if (coverImagePath == null) {
        song.albumArtUrl == null;
        await song.save();
        return null;
      } else {
        return File(coverImagePath);
      }
    }
  }

  Stream<List<Song>> get allSongs async* {
    // await Future.delayed(const Duration(milliseconds: 200));
    yield musicBox.values.toList();
    yield* musicBox.watch().map((event) => musicBox.values.toList());
  }

  Future<void> markFavorite(Song song) async {
    song.isFavorite = !song.isFavorite;
    await song.save();
  }
}
