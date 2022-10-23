import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../music_player.dart';

class SongCoverImage extends StatelessWidget {
  final Song song;
  final double height, width;
  final double borderRadius;

  const SongCoverImage({
    Key? key,
    required this.song,
    this.height = 54,
    this.width = 54,
    this.borderRadius = Constant.radiusMedium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColor.purple, borderRadius: BorderRadius.circular(borderRadius)),
      child: FutureBuilder<File?>(
        future: context.read<MusicCubit>().getCoverImage(song),
        builder: (context, snapshot) => snapshot.data != null
            ? Image.file(
                snapshot.data!,
                fit: BoxFit.cover,
              )
            : Center(
                child: Icon(
                  PhosphorIcons.musicNotes,
                  color: AppColor.offWhite,
                  size: height / 2,
                ),
              ),
      ),
    );
  }
}
