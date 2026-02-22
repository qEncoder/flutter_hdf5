import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hdf5_c_libs/hdf5_c_libs_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelHdf5CLibs platform = MethodChannelHdf5CLibs();
  const MethodChannel channel = MethodChannel('hdf5_c_libs');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
