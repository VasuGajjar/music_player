import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'music_player.dart';

export './app/app.dart';
export './core/core.dart';
export './theme/theme.dart';
export './util/util.dart';

class MusicPlayerApp extends StatelessWidget {
  final AudioPlayerHandler audioHandler;

  const MusicPlayerApp({Key? key, required this.audioHandler}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MusicCubit()..getSongs()),
        BlocProvider(create: (context) => PlaylistCubit()),
        BlocProvider(create: (context) => PlayerBloc(audioHandler.player)),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp(
          title: 'Music Player',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const CupertinoScrollBehavior(),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/': (context) => const HomeScreen(),
          },
          initialRoute: '/splash',
        ),
      ),
    );
  }
}
