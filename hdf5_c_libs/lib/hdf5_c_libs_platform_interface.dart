import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hdf5_c_libs_method_channel.dart';

abstract class Hdf5CLibsPlatform extends PlatformInterface {
  /// Constructs a Hdf5CLibsPlatform.
  Hdf5CLibsPlatform() : super(token: _token);

  static final Object _token = Object();

  static Hdf5CLibsPlatform _instance = MethodChannelHdf5CLibs();

  /// The default instance of [Hdf5CLibsPlatform] to use.
  ///
  /// Defaults to [MethodChannelHdf5CLibs].
  static Hdf5CLibsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Hdf5CLibsPlatform] when
  /// they register themselves.
  static set instance(Hdf5CLibsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
