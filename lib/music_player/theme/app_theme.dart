import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../music_player.dart';

class AppTheme {
  static ThemeData get lightTheme => _build(const ColorScheme.light(
        primary: AppColor.ink,
        onPrimary: AppColor.paper,
        secondary: AppColor.ink,
        onSecondary: AppColor.paper,
        surface: AppColor.paper,
        onSurface: AppColor.ink,
        onSurfaceVariant: Color(0xFF6B6B6B),
        surfaceContainerHighest: Color(0xFFEDEDED),
        surfaceContainerHigh: Color(0xFFF2F2F2),
        surfaceContainerLow: Colors.white,
        outlineVariant: Color(0xFFE2E2E2),
        error: Color(0xFFD32F2F),
      ));

  static ThemeData get darkTheme => _build(const ColorScheme.dark(
        primary: Color(0xFFF2F2F2),
        onPrimary: AppColor.ink,
        secondary: Color(0xFFF2F2F2),
        onSecondary: AppColor.ink,
        surface: Color(0xFF0E0E0E),
        onSurface: Color(0xFFF2F2F2),
        onSurfaceVariant: Color(0xFF9A9A9A),
        surfaceContainerHighest: Color(0xFF242424),
        surfaceContainerHigh: Color(0xFF1C1C1C),
        surfaceContainerLow: Color(0xFF161616),
        outlineVariant: Color(0xFF2A2A2A),
        error: Color(0xFFEF5350),
      ));

  static ThemeData _build(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: NoSplash.splashFactory,
      dividerColor: scheme.outlineVariant,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        systemOverlayStyle: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.transparent),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.onSurface,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: scheme.onSurface, width: 2)),
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.only(right: 24),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: Constant.paddingMedium),
        titleTextStyle: TextStyle(color: scheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500),
        subtitleTextStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
        iconColor: scheme.onSurfaceVariant,
        selectedColor: scheme.onSurface,
        selectedTileColor: scheme.surfaceContainerHigh,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constant.radiusSmall)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constant.radiusSmall)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: scheme.onSurface)),
      checkboxTheme: CheckboxThemeData(
        shape: const CircleBorder(),
        side: BorderSide(color: scheme.onSurfaceVariant, width: 1.5),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 2,
        activeTrackColor: scheme.onSurface,
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: scheme.onSurface,
        overlayColor: scheme.onSurface.withValues(alpha: 0.08),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6, elevation: 0, pressedElevation: 0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        trackShape: const RectangularSliderTrackShape(),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constant.radiusMedium)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.onSurface),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
