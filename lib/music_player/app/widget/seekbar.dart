import 'package:flutter/material.dart';

import '../../music_player.dart';

class SeekBar extends StatelessWidget {
  int songDuration, position;
  final Stream<int> positionStream;
  bool drag = false;
  void Function(int) onSeek;

  SeekBar({
    Key? key,
    required this.songDuration,
    required this.positionStream,
    required this.onSeek,
    this.position = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: positionStream,
      builder: (context, snapshot) => StatefulBuilder(
        builder: (context, setState) {
          if (!drag) {
            position = snapshot.data ?? 0;
          }
          return Slider(
            min: 0,
            max: songDuration.toDouble(),
            value: position.toDouble(),
            activeColor: AppColor.offWhite,
            inactiveColor: AppColor.offWhite.withOpacity(0.4),
            onChanged: (value) => setState(() {
              drag = true;
              position = value.toInt();
            }),
            onChangeEnd: (value) {
              drag = false;
              onSeek(position);
              position = snapshot.data ?? 0;
            },
          );
        },
      ),
    );
  }
}
