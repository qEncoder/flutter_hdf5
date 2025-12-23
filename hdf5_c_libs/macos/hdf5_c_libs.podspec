Pod::Spec.new do |s|
  s.name             = 'hdf5_c_libs'
  s.version          = '0.1.0'
  s.summary          = 'Flutter FFI plugin for HDF5'
  s.description      = 'Prebuilt HDF5 library as an xcframework for macOS'
  s.homepage         = 'https://github.com/qEncoder/flutter_hdf5'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'HDF5 Team' => 'contact@hdf5.dev' }

  s.source              = { :path => '.' }
  s.platform            = :osx, '10.14'
  s.dependency          'FlutterMacOS'
  s.vendored_frameworks = 'Libraries/hdf5_modular.xcframework'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
