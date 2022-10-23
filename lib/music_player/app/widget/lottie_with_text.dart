import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../music_player.dart';

class LottieWithText extends StatelessWidget {
  final String text;
  final String animation;

  const LottieWithText({
    Key? key,
    required this.animation,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          animation,
          width: 280,
          height: 180,
          repeat: false,
          fit: BoxFit.contain
        ),
        const SizedBox(height: Constant.paddingSmall),
        Text(
          text,
          style: TextStyle(color: AppColor.darkGray.withOpacity(0.6), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
