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
            Image.asset(Assets.logoImage, height: 64, width: 64),
            const SizedBox(height: Constant.paddingMedium),
            const Text('Music', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.4)),
          ],
        ),
      ),
    );
  }
}
