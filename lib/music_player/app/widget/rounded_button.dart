import 'package:flutter/material.dart';
import '../../music_player.dart';

class RoundedButton {
  static Widget textButton({
    IconData? icon,
    required String title,
    void Function()? onPress,
    Color primary = AppColor.darkBlue,
    TextStyle? textStyle,
    double? iconSize,
    double? cornerRadius,
    EdgeInsetsGeometry? padding,
  }) =>
      icon != null
          ? TextButton.icon(
              onPressed: onPress,
              style: TextButton.styleFrom(
                primary: primary,
                textStyle: textStyle,
                padding: padding,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cornerRadius ?? Constant.radiusSmall)),
              ),
              icon: Icon(icon, size: iconSize),
              label: Text(title),
            )
          : TextButton(
              onPressed: onPress,
              style: TextButton.styleFrom(
                primary: primary,
                textStyle: textStyle,
                padding: padding,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cornerRadius ?? Constant.radiusSmall)),
              ),
              child: Text(title),
            );

  static Widget elevatedButton({
    IconData? icon,
    required String title,
    void Function()? onPress,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? shadowColor,
    TextStyle? textStyle,
    double? iconSize,
    double? cornerRadius,
    EdgeInsetsGeometry? padding,
  }) =>
      icon != null
          ? ElevatedButton.icon(
              onPressed: onPress,
              style: ElevatedButton.styleFrom(
                primary: backgroundColor,
                onPrimary: foregroundColor,
                shadowColor: shadowColor,
                textStyle: textStyle,
                padding: padding,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cornerRadius ?? Constant.radiusSmall)),
              ),
              icon: Icon(icon, size: iconSize),
              label: Text(title),
            )
          : TextButton(
              onPressed: onPress,
              style: ElevatedButton.styleFrom(
                primary: backgroundColor,
                onPrimary: foregroundColor,
                shadowColor: shadowColor,
                textStyle: textStyle,
                padding: padding,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cornerRadius ?? Constant.radiusSmall)),
              ),
              child: Text(title),
            );

  static Widget semitransparentButton({
    IconData? icon,
    required String title,
    void Function()? onPress,
    Color color = AppColor.darkBlue,
    TextStyle? textStyle = TextStyles.p2Normal,
    double? iconSize = 18,
    double? cornerRadius,
    EdgeInsetsGeometry? padding,
    double opacity = 0.3,
  }) =>
      icon != null
          ? ElevatedButton.icon(
              onPressed: onPress,
              style: ElevatedButton.styleFrom(
                primary: color.withOpacity(opacity),
                onPrimary: color,
                shadowColor: Colors.transparent,
                textStyle: textStyle,
                padding: padding,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cornerRadius ?? Constant.radiusSmall)),
              ),
              icon: Icon(icon, size: iconSize),
              label: Text(title),
            )
          : TextButton(
              onPressed: onPress,
              style: ElevatedButton.styleFrom(
                primary: color.withOpacity(opacity),
                onPrimary: color,
                shadowColor: Colors.transparent,
                textStyle: textStyle,
                padding: padding,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cornerRadius ?? Constant.radiusSmall)),
              ),
              child: Text(title),
            );
}
