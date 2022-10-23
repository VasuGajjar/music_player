import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../music_player.dart';

class AnimatedScaffold extends StatefulWidget {
  final Widget body, bottomBar, drawer;
  final PreferredSizeWidget appBar;
  final Color drawerBackgroundColor, scaffoldBackgroundColor;
  final Future<bool> Function()? onBackPress;

  const AnimatedScaffold({
    Key? key,
    required this.appBar,
    required this.drawer,
    required this.body,
    required this.bottomBar,
    this.onBackPress,
    this.drawerBackgroundColor = AppColor.darkBlue,
    this.scaffoldBackgroundColor = AppColor.offWhite,
  }) : super(key: key);

  @override
  State<AnimatedScaffold> createState() => AnimatedScaffoldState();
}

class AnimatedScaffoldState extends State<AnimatedScaffold> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _curve = Curves.fastOutSlowIn;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_animationController.value != 0) {
          await closeDrawer();
          return false;
        } else {
          if (widget.onBackPress != null) {
            return widget.onBackPress!();
          } else {
            return true;
          }
        }
      },
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, _) {
            double slide = 240 * _animationController.value;
            double scale = 1 - (0.2 * _animationController.value);
            double rotate = (-math.pi / 32) * _animationController.value;
            double cornerRadius = 36 * _animationController.value;

            return Stack(
              children: [
                Expanded(
                  child: Container(
                    color: widget.drawerBackgroundColor,
                    child: widget.drawer,
                  ),
                ),
                Transform(
                  transform: Matrix4.identity()
                    ..translate(slide)
                    ..scale(scale)
                    ..rotateZ(rotate),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(cornerRadius),
                    child: Scaffold(
                      appBar: widget.appBar,
                      body: widget.body,
                      bottomNavigationBar: widget.bottomBar,
                      backgroundColor: widget.scaffoldBackgroundColor,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> openDrawer() => _animationController.isDismissed ? _animationController.animateTo(1, curve: _curve) : Future.delayed(Duration.zero);

  Future<void> closeDrawer() => _animationController.isDismissed ? Future.delayed(Duration.zero) : _animationController.animateBack(0, curve: _curve);

  void update() => setState(() {});
}
