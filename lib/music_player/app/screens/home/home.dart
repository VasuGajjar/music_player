import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../music_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int currentPage = 0;
  late TabController tabController = TabController(length: pages.length, vsync: this);

  final List<Widget> pages = const [
    MusicPage(),
    FavoritePage(),
    PlaylistPage(),
  ];

  @override
  void initState() {
    super.initState();
    tabController.addListener(tabControllerListener);
  }

  void tabControllerListener() => setState(() => currentPage = tabController.index);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music'),
        titleSpacing: Constant.paddingMedium,
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => showSearch<Song?>(context: context, delegate: Search()).then((value) {
              if (value == null || !context.mounted) return;

              var songs = context.read<MusicCubit>().state.songs;
              int index = songs.indexOf(value);
              context.read<PlayerBloc>().add(PlayerNewSong(songs: songs, currentIndex: index));
            }),
            icon: const Icon(PhosphorIcons.magnifyingGlass),
          ),
          IconButton(
            tooltip: isDark ? 'Light mode' : 'Dark mode',
            onPressed: () => context.read<ThemeCubit>().toggle(Theme.of(context).brightness),
            icon: Icon(isDark ? PhosphorIcons.sun : PhosphorIcons.moon),
          ),
          IconButton(
            tooltip: 'About',
            onPressed: () => showDialog(context: context, builder: (context) => const AboutScreen()),
            icon: const Icon(PhosphorIcons.info),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          padding: const EdgeInsets.symmetric(horizontal: Constant.paddingMedium),
          tabs: const [
            Tab(text: 'Songs'),
            Tab(text: 'Favorites'),
            Tab(text: 'Playlists'),
          ],
        ),
      ),
      body: TabBarView(controller: tabController, children: pages),
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        heroTag: 'Home',
        tooltip: currentPage == 2 ? 'New playlist' : 'Shuffle',
        onPressed: () {
          if (currentPage == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateEditPlaylist()));
            return;
          }

          var songs = context.read<MusicCubit>().state.songs;
          if (currentPage == 1) songs = songs.where((element) => element.isFavorite).toList();
          if (songs.isEmpty) return;

          context.read<PlayerBloc>()
            ..add(PlayerNewSong(songs: songs, currentIndex: Random().nextInt(songs.length)))
            ..add(PlayerShuffle(true))
            ..add(PlayerPlayPause(true));
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(currentPage == 2 ? PhosphorIcons.plus : PhosphorIcons.shuffle, key: ValueKey(currentPage == 2)),
        ),
      ),
      bottomNavigationBar: const PlayerTile(),
    );
  }

  @override
  void dispose() {
    tabController.removeListener(tabControllerListener);
    tabController.dispose();
    super.dispose();
  }
}
