import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'storage_helper_platform_interface.dart';

/// An implementation of [StorageHelperPlatform] that uses method channels.
class MethodChannelStorageHelper extends StorageHelperPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('storage_helper');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<String>> getSongs() async {
    final songs = await methodChannel.invokeListMethod<String>('getSongs') ?? [];
    return songs;
  }
}
