import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'storage_helper_method_channel.dart';

abstract class StorageHelperPlatform extends PlatformInterface {
  /// Constructs a StorageHelperPlatform.
  StorageHelperPlatform() : super(token: _token);

  static final Object _token = Object();

  static StorageHelperPlatform _instance = MethodChannelStorageHelper();

  /// The default instance of [StorageHelperPlatform] to use.
  ///
  /// Defaults to [MethodChannelStorageHelper].
  static StorageHelperPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StorageHelperPlatform] when
  /// they register themselves.
  static set instance(StorageHelperPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<String>> getSongs() {
    throw UnimplementedError('getSongs() has not been implemented.');
  }
}
