import 'package:flutter_test/flutter_test.dart';
import 'package:hdf5_c_libs/hdf5_c_libs.dart';
import 'package:hdf5_c_libs/hdf5_c_libs_platform_interface.dart';
import 'package:hdf5_c_libs/hdf5_c_libs_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHdf5CLibsPlatform
    with MockPlatformInterfaceMixin
    implements Hdf5CLibsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final Hdf5CLibsPlatform initialPlatform = Hdf5CLibsPlatform.instance;

  test('$MethodChannelHdf5CLibs is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHdf5CLibs>());
  });

  test('getPlatformVersion', () async {
    Hdf5CLibs hdf5CLibsPlugin = Hdf5CLibs();
    MockHdf5CLibsPlatform fakePlatform = MockHdf5CLibsPlatform();
    Hdf5CLibsPlatform.instance = fakePlatform;

    expect(await hdf5CLibsPlugin.getPlatformVersion(), '42');
  });
}
