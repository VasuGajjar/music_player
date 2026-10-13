import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class FavoriteIconButton extends StatefulWidget {
  final bool isActive;
  final void Function(bool value) onPressed;
  final double size;

  const FavoriteIconButton({
    Key? key,
    required this.isActive,
    required this.onPressed,
    this.size = 20,
  }) : super(key: key);

  @override
  State<FavoriteIconButton> createState() => _FavoriteIconButtonState();
}

class _FavoriteIconButtonState extends State<FavoriteIconButton> {
  late bool isActive = widget.isActive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: () {
        setState(() => isActive = !isActive);
        widget.onPressed(isActive);
      },
      iconSize: widget.size,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
        child: Icon(
          isActive ? PhosphorIcons.heartFill : PhosphorIcons.heart,
          key: ValueKey(isActive),
          color: isActive ? scheme.onSurface : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
