import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:storage_helper/storage_helper.dart';

import 'music_player/music_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Initializing Storage and Datastore
  final directory = await StorageHelper.getDocumentsDirectory();
  await Hive.initFlutter(directory.path);
  Hive.registerAdapter(SongAdapter());
  await Hive.openBox<Song>(Constant.musicBox);
  Hive.registerAdapter(PlaylistAdapter());
  await Hive.openBox<Playlist>(Constant.playlistBox);
  HydratedBloc.storage = await HydratedStorage.build(storageDirectory: HydratedStorageDirectory(directory.path));

  // Initializing Player Notification (needs the music box for the favorite button)
  final audioHandler = await AudioService.init(
    builder: AudioPlayerHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.vasugajjar.music_player.player',
      androidNotificationChannelName: 'Music Player',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'drawable/ic_stat_music',
      // Embedded covers can be huge; the notification only needs a small bitmap.
      artDownscaleWidth: 512,
      artDownscaleHeight: 512,
    ),
  );

  // Running Application
  runApp(MusicPlayerApp(audioHandler: audioHandler));
}
