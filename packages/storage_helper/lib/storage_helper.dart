import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'storage_helper_platform_interface.dart';

class StorageHelperException implements Exception {
  final String message;

  const StorageHelperException([String? msg]) : message = msg ?? 'Something went wrong';
}

class StorageHelper {
  Future<String?> getPlatformVersion() {
    return StorageHelperPlatform.instance.getPlatformVersion();
  }

  static Future<List<String>> getAudioList() async {
    if (!kIsWeb) {
      try {
        var songs = await StorageHelperPlatform.instance.getSongs();
        return songs;
      } on PlatformException catch (e) {
        throw StorageHelperException(e.message);
      } catch (_) {
        throw const StorageHelperException();
      }
    } else {
      throw const StorageHelperException('Does not support web platform');
    }
  }

  static Future<String?> getAlbumCover(String title, Uint8List? albumCover) async {
    try {
      if (albumCover != null) {
        var tempDir = await getTemporaryDirectory();
        var file = File(path.join(tempDir.path, '$title.png'));
        if (file.existsSync()) {
          return file.path;
        } else {
          file.createSync();
          file.writeAsBytesSync(albumCover);
          return file.path;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getAlbumCoverPath(String title, Uint8List? albumCover) async {
    try {
      if (albumCover != null) {
        var tempDir = await getTemporaryDirectory();
        return path.join(tempDir.path, '$title.png');
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Directory> getDocumentsDirectory() => getApplicationDocumentsDirectory();
}
