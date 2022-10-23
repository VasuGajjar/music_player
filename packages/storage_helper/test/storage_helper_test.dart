import 'package:flutter_test/flutter_test.dart';
import 'package:storage_helper/storage_helper.dart';
import 'package:storage_helper/storage_helper_platform_interface.dart';
import 'package:storage_helper/storage_helper_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockStorageHelperPlatform with MockPlatformInterfaceMixin implements StorageHelperPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<List<String>> getSongs() => Future.value(['']);
}

void main() {
  final StorageHelperPlatform initialPlatform = StorageHelperPlatform.instance;

  test('$MethodChannelStorageHelper is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelStorageHelper>());
  });

  test('getPlatformVersion', () async {
    StorageHelper storageHelperPlugin = StorageHelper();
    MockStorageHelperPlatform fakePlatform = MockStorageHelperPlatform();
    StorageHelperPlatform.instance = fakePlatform;

    expect(await storageHelperPlugin.getPlatformVersion(), '42');
  });
}
