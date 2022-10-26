import 'dart:async';

import 'package:flutter/material.dart';

class SeekBar extends StatefulWidget {
  final Stream<Duration?> songDuration;
  final Stream<Duration> songPosition;
  final Color initialColor;
  final void Function(int position) onSeek;

  const SeekBar({
    Key? key,
    required this.songDuration,
    required this.songPosition,
    required this.onSeek,
    required this.initialColor,
  }) : super(key: key);

  @override
  State<SeekBar> createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  Duration? songDuration;
  Duration songPosition = Duration.zero;
  bool dragging = false;
  double seekBarValue = 0, maxValue = 0;
  late Color color;
  late StreamSubscription durationSubscription, positionSubscription;

  @override
  void initState() {
    durationSubscription = widget.songDuration.listen((duration) async => setState(() => songDuration = duration));
    positionSubscription = widget.songPosition.listen((position) async => setState(() => songPosition = position));
    color = widget.initialColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    seekBarValue = dragging ? seekBarValue : songPosition.inSeconds.toDouble();
    maxValue = songDuration?.inSeconds.toDouble() ?? 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          strFromDuration(songPosition),
          style: TextStyle(color: color.withOpacity(0.7)),
        ),
        Expanded(
          child: Slider(
            onChanged: (value) {
              dragging = true;
              setState(() => seekBarValue = value);
            },
            onChangeEnd: (value) {
              dragging = false;
              widget.onSeek(value.toInt());
            },
            max: maxValue,
            value: seekBarValue,
            activeColor: color.withOpacity(0.5),
            inactiveColor: color.withOpacity(0.1),
            thumbColor: color.withOpacity(1),
          ),
        ),
        Text(
          strFromDuration(songDuration ?? Duration.zero),
          style: TextStyle(color: color.withOpacity(0.7)),
        ),
      ],
    );
  }

  String strFromDuration(Duration duration) => duration.toString().substring(
        duration.toString().indexOf(':') + 1,
        duration.toString().indexOf('.'),
      );

  void changeColor(Color color) => setState(() => this.color = color);

  @override
  void dispose() {
    durationSubscription.cancel();
    positionSubscription.cancel();
    super.dispose();
  }
}
