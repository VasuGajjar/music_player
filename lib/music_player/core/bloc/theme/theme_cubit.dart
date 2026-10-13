import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  /// Flips to the opposite of whatever is currently shown, so it also works
  /// while still following the system setting.
  void toggle(Brightness current) => emit(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) => ThemeMode.values[json['mode'] as int];

  @override
  Map<String, dynamic>? toJson(ThemeMode state) => {'mode': state.index};
}
