import 'package:flutter/material.dart';

import '../../../music_player.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 1),
      () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              Assets.logoImage,
              height: 80,
              width: 80,
            ),
            const SizedBox(height: Constant.paddingLarge),
            const Text.rich(
              TextSpan(text: 'Music ', children: [
                TextSpan(
                  text: 'Player',
                  style: TextStyle(color: AppColor.darkPurple),
                ),
              ]),
              style: TextStyles.h1Bold,
            ),
          ],
        ),
      ),
    );
  }
}
