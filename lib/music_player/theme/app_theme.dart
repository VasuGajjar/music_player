import 'package:flutter/material.dart';

import '../music_player.dart';

class AppTheme {
  static ThemeData get lightTheme {
    ThemeData lightTheme = ThemeData.light();
    return lightTheme.copyWith(
      colorScheme: lightTheme.colorScheme.copyWith(
        primary: AppColor.darkBlue,
        onPrimary: AppColor.offWhite,
        secondary: AppColor.purple,
        onSecondary: AppColor.offWhite,
        error: AppColor.red,
        onError: AppColor.offWhite,
        background: AppColor.offWhite,
        onBackground: AppColor.darkGray,
      ),
      appBarTheme: lightTheme.appBarTheme.copyWith(
        foregroundColor: AppColor.darkGray,
        backgroundColor: AppColor.offWhite,
        shadowColor: AppColor.darkGray.withOpacity(0.2),
        elevation: 8,
        centerTitle: true,
      ),
      textTheme: lightTheme.textTheme.apply(
        displayColor: AppColor.darkGray,
        bodyColor: AppColor.darkGray,
      ),
      dividerColor: Colors.transparent,
      primaryColor: AppColor.darkBlue,
      scaffoldBackgroundColor: AppColor.offWhite,
      cardColor: AppColor.white,
    );
  }
}
