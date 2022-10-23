import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../music_player.dart';

class PlayPauseButton extends StatelessWidget {
  final bool state, mini;
  final Color color;
  final void Function(bool) onPlayPauseTap;

  const PlayPauseButton({
    Key? key,
    this.state = true,
    this.mini = true,
    this.color = AppColor.offWhite,
    required this.onPlayPauseTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => onPlayPauseTap(!state),
      mini: mini,
      backgroundColor: color,
      splashColor: AppColor.darkBlue.withOpacity(0.6),
      foregroundColor: AppColor.darkGray,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        ),
        switchInCurve: Curves.decelerate,
        switchOutCurve: Curves.easeOut,
        child: Icon(
          state ? PhosphorIcons.pauseFill : PhosphorIcons.playFill,
          size: mini ? 18 : null,
          key: state ? const Key('1') : const Key('2'),
        ),
      ),
    );
  }
}
