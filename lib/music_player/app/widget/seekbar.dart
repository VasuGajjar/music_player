import 'dart:async';

import 'package:flutter/material.dart';

class SeekBar extends StatefulWidget {
  final Stream<Duration?> songDuration;
  final Stream<Duration> songPosition;
  final void Function(int position) onSeek;

  const SeekBar({
    Key? key,
    required this.songDuration,
    required this.songPosition,
    required this.onSeek,
  }) : super(key: key);

  @override
  State<SeekBar> createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  Duration? songDuration;
  Duration songPosition = Duration.zero;
  bool dragging = false;
  double seekBarValue = 0, maxValue = 0;
  late StreamSubscription durationSubscription, positionSubscription;

  @override
  void initState() {
    durationSubscription = widget.songDuration.listen((duration) async => setState(() => songDuration = duration));
    positionSubscription = widget.songPosition.listen((position) async => setState(() => songPosition = position));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final timeStyle = TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant);
    maxValue = songDuration?.inSeconds.toDouble() ?? 1;
    seekBarValue = (dragging ? seekBarValue : songPosition.inSeconds.toDouble()).clamp(0, maxValue);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
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
        ),
        Padding(
          // Matches the slider's overlay radius so the labels line up with the track ends.
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(strFromDuration(songPosition), style: timeStyle),
              Text(strFromDuration(songDuration ?? Duration.zero), style: timeStyle),
            ],
          ),
        ),
      ],
    );
  }

  String strFromDuration(Duration duration) => duration.toString().substring(
        duration.toString().indexOf(':') + 1,
        duration.toString().indexOf('.'),
      );

  @override
  void dispose() {
    durationSubscription.cancel();
    positionSubscription.cancel();
    super.dispose();
  }
}
