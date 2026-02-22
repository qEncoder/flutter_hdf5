import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hdf5_c_libs_platform_interface.dart';

/// An implementation of [Hdf5CLibsPlatform] that uses method channels.
class MethodChannelHdf5CLibs extends Hdf5CLibsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hdf5_c_libs');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
