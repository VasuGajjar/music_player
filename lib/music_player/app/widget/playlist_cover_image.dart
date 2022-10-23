import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../music_player.dart';

class PlaylistCoverImage extends StatelessWidget {
  final Playlist playlist;
  final double height, width;
  final double borderRadius;

  const PlaylistCoverImage({
    Key? key,
    required this.playlist,
    this.height = 120,
    this.width = 120,
    this.borderRadius = Constant.radiusMedium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColor.purple, borderRadius: BorderRadius.circular(borderRadius)),
      child: Builder(
        builder: (context) {
          if (playlist.songs.length >= 4) {
            return Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: SongCoverImage(
                          song: playlist.songs[0],
                          borderRadius: 0,
                          height: double.infinity,
                        ),
                      ),
                      Expanded(
                        child: SongCoverImage(
                          song: playlist.songs[1],
                          borderRadius: 0,
                          height: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: SongCoverImage(
                          song: playlist.songs[2],
                          borderRadius: 0,
                          height: double.infinity,
                        ),
                      ),
                      Expanded(
                        child: SongCoverImage(
                          song: playlist.songs[3],
                          borderRadius: 0,
                          height: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (playlist.songs.length >= 2) {
            return Row(
              children: [
                Expanded(
                  child: SongCoverImage(
                    song: playlist.songs[0],
                    borderRadius: 0,
                    height: double.infinity,
                  ),
                ),
                Expanded(
                  child: SongCoverImage(
                    song: playlist.songs[1],
                    borderRadius: 0,
                    height: double.infinity,
                  ),
                ),
              ],
            );
          } else if (playlist.songs.length == 1) {
            return SongCoverImage(
              song: playlist.songs[0],
              height: height,
              width: width,
              borderRadius: 0,
            );
          } else {
            return Center(
              child: Icon(
                PhosphorIcons.musicNotes,
                color: AppColor.offWhite,
                size: height / 2,
              ),
            );
          }
        },
      ),
    );
  }
}
