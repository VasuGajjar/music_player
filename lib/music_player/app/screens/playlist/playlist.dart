import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../music_player.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, state) {
        if (state.status.isLoading) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LottieWithText(
                animation: Assets.pandaAnimation,
                text: 'No Playlist Found',
              ),
              const SizedBox(height: 8),
              RoundedButton.semitransparentButton(
                onPress: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateEditPlaylist()),
                ),
                icon: PhosphorIcons.plus,
                title: 'Create One',
                color: AppColor.darkPurple,
              ),
            ],
          );
        } else if (state.status.isFailure) {
          return Center(
            child: LottieWithText(
              animation: Assets.errorAnimation,
              text: state.error,
            ),
          );
        } else if (state.status.isSuccess) {
          if (state.playlists.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LottieWithText(
                  animation: Assets.pandaAnimation,
                  text: 'No Playlist Found',
                ),
                const SizedBox(height: 8),
                RoundedButton.semitransparentButton(
                  onPress: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateEditPlaylist()),
                  ),
                  icon: PhosphorIcons.plus,
                  title: 'Create One',
                  color: AppColor.darkPurple,
                ),
              ],
            );
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                crossAxisCount: 2,
                childAspectRatio: 0.85,
              ),
              itemCount: state.playlists.length,
              padding: const EdgeInsets.all(Constant.paddingMedium),
              itemBuilder: (BuildContext context, int index) => playlistTile(context, state.playlists[index]),
            );
          }
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

playlistTile(BuildContext context, Playlist playlist) => InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlaylistSongScreen(playlist: playlist)),
      ),
      borderRadius: BorderRadius.circular(Constant.radiusMedium),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constant.radiusMedium)),
        child: Column(
          children: [
            Expanded(
              child: PlaylistCoverImage(
                playlist: playlist,
                width: double.infinity,
                borderRadius: 0,
              ),
            ),
            ListTile(
              title: Text(playlist.name),
              subtitle: Text('${playlist.songs.length} Tracks'),
              trailing: PlayPauseButton(
                state: false,
                color: AppColor.white,
                onPlayPauseTap: (value) => context.read<PlayerBloc>()
                  ..add(PlayerNewSong(songs: playlist.songs, currentIndex: 0))
                  ..add(PlayerPlayPause(true)),
              ),
            ),
          ],
        ),
      ),
    );
