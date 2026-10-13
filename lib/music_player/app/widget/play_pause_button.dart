import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class PlayPauseButton extends StatelessWidget {
  final bool state, mini;
  final void Function(bool) onPlayPauseTap;

  const PlayPauseButton({
    Key? key,
    this.state = true,
    this.mini = true,
    required this.onPlayPauseTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = mini ? 40.0 : 72.0;
    return SizedBox.square(
      dimension: size,
      child: IconButton.filled(
        onPressed: () => onPlayPauseTap(!state),
        style: IconButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary),
        iconSize: mini ? 18 : 30,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: Icon(
            state ? PhosphorIcons.pauseFill : PhosphorIcons.playFill,
            key: ValueKey(state),
          ),
        ),
      ),
    );
  }
}
