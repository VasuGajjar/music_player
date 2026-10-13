import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as path;
import 'package:storage_helper/storage_helper.dart';

import '../../music_player.dart';

class MusicRepository {
  final Box<Song> musicBox = Hive.box<Song>(Constant.musicBox);

  Future<void> fetchSongsFromStorage() async {
    List<String> storageSongs = await StorageHelper.getAudioList();
    Logger.data('Songs: ${storageSongs.toString()}');
    List<String> datastoreSongs =
        musicBox.values.map((e) => e.filePath).toList();

    // Deleting songs from datastore which are not present in storage
    for (var song in datastoreSongs) {
      if (!storageSongs.contains(song)) {
        musicBox.delete(song);
      }
    }

    // Add songs to datastore which are not present in datastore
    for (var songPath in storageSongs) {
      if (!datastoreSongs.contains(songPath)) {
        try {
          var metadata = await _readMetadata(songPath);
          String trackName = metadata?.title ?? path.basename(songPath);
          await addSong(
            songPath,
            title: trackName,
            artist: metadata?.artist ?? 'NA',
            album: metadata?.album ?? 'NA',
            cover: await StorageHelper.getAlbumCover(trackName, _albumArt(metadata)),
          );
        } catch (e) {
          Logger.error('MusicRepo.fetchSongsFromStorage().error: ', e);
        }
      }
    }

    // Covers are cached in the temp dir, which Android may clear. Re-extract missing
    // ones here once, instead of checking on every cover widget build.
    for (var song in musicBox.values.toList()) {
      if (song.albumArtUrl != null && !await File(song.albumArtUrl!).exists()) {
        var metadata = await _readMetadata(song.filePath);
        song.albumArtUrl =
            await StorageHelper.getAlbumCover(song.title, _albumArt(metadata));
        await song.save();
      }
    }
  }


  /// Stores a song with known metadata; also used for downloads, whose tags we already know.
  Future<void> addSong(String songPath, {required String title, required String artist, String album = 'NA', String? cover}) async {
    Color dominantColor = AppColor.darkBlue;
    Color textColor = AppColor.offWhite;
    if (cover != null) {
      PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(FileImage(File(cover)));
      dominantColor = paletteGenerator.dominantColor?.color ?? dominantColor;
      textColor = paletteGenerator.dominantColor?.titleTextColor ?? textColor;
    }
    await musicBox.put(
      songPath,
      Song(
        title: title,
        artist: artist,
        album: album,
        albumArtUrl: cover,
        filePath: songPath,
        isFavorite: false,
        dominantColor: dominantColor.value,
        textColor: textColor.value,
      ),
    );
  }

  // Parsing is synchronous file I/O, so keep it off the UI isolate. Static so the
  // closure doesn't capture `this` (Hive boxes can't cross isolates).
  // Returns null for formats the parser doesn't support; callers fall back to the filename.
  static Future<AudioMetadata?> _readMetadata(String filePath) async {
    try {
      return await Isolate.run(
          () => readMetadata(File(filePath), getImage: true));
    } catch (e) {
      Logger.error('MusicRepo._readMetadata().error: ', e);
      return null;
    }
  }

  static Uint8List? _albumArt(AudioMetadata? metadata) =>
      metadata?.pictures.firstOrNull?.bytes;

  Stream<List<Song>> get allSongs async* {
    // await Future.delayed(const Duration(milliseconds: 200));
    yield musicBox.values.toList();
    yield* musicBox.watch().map((event) => musicBox.values.toList());
  }

  Future<void> markFavorite(Song song) async {
    // Songs restored with the player queue are detached copies; update the stored one.
    final stored = musicBox.get(song.filePath);
    if (stored == null) return;
    stored.isFavorite = !stored.isFavorite;
    if (!identical(stored, song)) song.isFavorite = stored.isFavorite;
    await stored.save();
  }
}
