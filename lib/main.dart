import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:storage_helper/storage_helper.dart';

import 'music_player/music_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Initializing Player Notification
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.vasugajjar.music_player.player',
    androidNotificationChannelName: 'Music Player',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'mipmap/ic_launcher_adaptive_fore',
  );

  // Initializing Storage and Datastore
  final directory = await StorageHelper.getDocumentsDirectory();
  await Hive.initFlutter(directory.path);
  Hive.registerAdapter(SongAdapter());
  await Hive.openBox<Song>(Constant.musicBox);
  Hive.registerAdapter(PlaylistAdapter());
  await Hive.openBox<Playlist>(Constant.playlistBox);
  final storage = await HydratedStorage.build(storageDirectory: directory);

  // Running Application
  HydratedBlocOverrides.runZoned(
    () => runApp(const MusicPlayerApp()),
    storage: storage,
  );
}
