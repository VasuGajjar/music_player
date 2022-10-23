import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../music_player.dart';

class FavoriteIconButton extends StatefulWidget {
  final bool isActive;
  final void Function(bool value) onPressed;
  final double size;
  final Color? color;

  const FavoriteIconButton({
    Key? key,
    required this.isActive,
    required this.onPressed,
    this.color,
    this.size = 48,
  }) : super(key: key);

  @override
  State<FavoriteIconButton> createState() => _FavoriteIconButtonState();
}

class _FavoriteIconButtonState extends State<FavoriteIconButton> {
  late bool isActive;
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    isActive = widget.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          if (isActive)
            Lottie.asset(
              Assets.favoriteAnimation,
              animate: isAnimating && isActive,
              repeat: false,
            ),
          IconButton(
            onPressed: () {
              isActive = !isActive;
              isAnimating = true;
              widget.onPressed(isActive);
              Future.delayed(const Duration(milliseconds: 500), () => isAnimating = false);
              setState(() {});
            },
            iconSize: widget.size / 2,
            icon: Icon(
              isActive ? PhosphorIcons.heartFill : PhosphorIcons.heart,
              color: isActive ? AppColor.red : widget.color,
            ),
          ),
        ],
      ),
    );
  }
}
