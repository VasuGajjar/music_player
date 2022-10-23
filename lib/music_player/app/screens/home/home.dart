import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../music_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int currentPage = 0;
  late TabController tabController = TabController(
    length: pages.length,
    vsync: this,
  );

  final List<Tab> tabs = [
    Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(PhosphorIcons.musicNotesFill, size: 18),
          SizedBox(width: 8),
          Text('All Songs'),
        ],
      ),
    ),
    Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(PhosphorIcons.heartFill, size: 18),
          SizedBox(width: 8),
          Text('Favorites'),
        ],
      ),
    ),
    Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(PhosphorIcons.playlistFill, size: 18),
          SizedBox(width: 8),
          Text('Playlist'),
        ],
      ),
    ),
  ];

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
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          statusBarColor: AppColor.darkGray.withOpacity(0.4),
          systemNavigationBarColor: AppColor.offWhite,
          systemNavigationBarDividerColor: AppColor.offWhite,
        ),
        leading: IconButton(
          onPressed: () => showSearch<Song?>(context: context, delegate: Search()).then((value) {
            if (value == null) return;

            var songs = context.read<MusicCubit>().state.songs;
            int index = songs.indexOf(value);
            context.read<PlayerBloc>().add(PlayerNewSong(songs: songs, currentIndex: index));
          }),
          icon: const Icon(PhosphorIcons.magnifyingGlass),
        ),
        title: const Text.rich(
          TextSpan(text: 'Music ', children: [
            TextSpan(
              text: 'Player',
              style: TextStyle(color: AppColor.darkPurple),
            ),
          ]),
        ),
        actions: [
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(PhosphorIcons.gear),
          // ),
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const AboutScreen(),
            ),
            icon: const Icon(PhosphorIcons.info),
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: tabs,
          unselectedLabelColor: AppColor.darkGray,
          indicatorColor: AppColor.darkPurple,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppColor.darkPurple,
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: pages,
      ),
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        heroTag: 'Home',
        onPressed: () {
          if (currentPage == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateEditPlaylist()),
            );
          } else {
            List<Song> songs;
            int currentIndex;

            if (currentPage == 0) {
              songs = context.read<MusicCubit>().state.songs;
            } else {
              songs = context.read<MusicCubit>().state.songs.where((element) => element.isFavorite).toList();
            }
            currentIndex = Random().nextInt(songs.length);

            context.read<PlayerBloc>()
              ..add(PlayerNewSong(songs: songs, currentIndex: currentIndex))
              ..add(PlayerShuffle(true))
              ..add(PlayerPlayPause(true));
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constant.radiusMedium)),
        child: AnimatedCrossFade(
          firstChild: const Icon(PhosphorIcons.shuffle),
          secondChild: const Icon(PhosphorIcons.plus),
          crossFadeState: currentPage == 2 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 400),
        ),
      ),
      bottomNavigationBar: PlayerTile(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(Constant.radiusMedium),
            ),
          ),
          builder: (context) => const PlayerScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    tabController.removeListener(tabControllerListener);
    tabController.dispose();
    super.dispose();
  }
}
