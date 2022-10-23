import 'dart:developer' show log;

class Logger {
  static const bool print = true;

  static void error(String message, [Object? error]) => print ? log(message, error: error, level: 1) : null;

  static void data(String message) => print ? log(message, level: 2) : null;

  static void debug(String message) => print ? log(message, level: 3) : null;
}
