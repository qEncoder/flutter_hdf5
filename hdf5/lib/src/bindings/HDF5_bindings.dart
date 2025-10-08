import 'dart:ffi';
import 'dart:io';

export 'H5.dart'
    show
        H5P_DEFAULT,
        H5_INDEX_UNKNOWN,
        H5_INDEX_NAME,
        H5_INDEX_CRT_ORDER,
        H5_INDEX_N,
        H5_ITER_UNKNOWN,
        H5_ITER_INC,
        H5_ITER_DEC,
        H5_ITER_NATIVE,
        H5_ITER_N;
export 'H5F.dart'
    show H5F_ACC_RDONLY, H5F_ACC_RDWR, H5F_ACC_SWMR_WRITE, H5F_ACC_SWMR_READ;
export 'H5D.dart' show H5D_layout_t;
export 'H5L.dart' show H5L_info_t, H5L_type_t;
export 'H5O.dart'
    show
        H5O_info_t,
        H5O_type_t,
        H5O_INFO_BASIC,
        H5O_INFO_TIME,
        H5O_INFO_NUM_ATTRS,
        H5O_INFO_HDR,
        H5O_INFO_META_SIZE,
        H5O_INFO_ALL;
export 'H5T.dart' show H5T_class_t;
export 'H5S.dart' show H5S_ALL, H5S_seloper_t;
export 'H5P.dart' show FilterSettings;
export 'H5R.dart' show H5R_type_t;
export 'H5Z.dart' show H5Z_filter_t;

import 'package:hdf5/src/utility/logging.dart';

import 'H5.dart';
import 'H5A.dart';
import 'H5D.dart';
import 'H5F.dart';
import 'H5G.dart';
import 'H5L.dart';
import 'H5P.dart';
import 'H5S.dart';
import 'H5T.dart';
import 'H5O.dart';
import 'H5R.dart';

class HDF5Bindings {
  static final HDF5Bindings __instance = HDF5Bindings.__new__();
  late final H5Bindings H5;
  late final H5ABindings H5A;
  late final H5DBindings H5D;
  late final H5FBindings H5F;
  late final H5GBindings H5G;
  late final H5LBindings H5L;
  late final H5PBindings H5P;
  late final H5SBindings H5S;
  late final H5TBindings H5T;
  late final H5OBindings H5O;
  late final H5RBindings H5R;

  factory HDF5Bindings() {
    return __instance;
  }

  HDF5Bindings.__new__() {
    String libraryPath;

    libraryPath = 'hdf5.so';
    if (Platform.isMacOS) {
      // Load from xcframework bundled via CocoaPods
      libraryPath = 'hdf5_modular.framework/hdf5_modular';
    } else if (Platform.isWindows) {
      libraryPath = 'hdf5.dll';
    }
    logger.info("Loading HDF5 library from $libraryPath");
    final DynamicLibrary HDF5Lib = DynamicLibrary.open(libraryPath);
    logger.info('HDF5 library loaded');

    // initialize the library (needed to load the values of the constants)
    H5 = H5Bindings(HDF5Lib)..open();
    H5A = H5ABindings(HDF5Lib);
    H5D = H5DBindings(HDF5Lib);
    H5F = H5FBindings(HDF5Lib);
    H5G = H5GBindings(HDF5Lib);
    H5L = H5LBindings(HDF5Lib);
    H5P = H5PBindings(HDF5Lib);
    H5S = H5SBindings(HDF5Lib);
    H5T = H5TBindings(HDF5Lib);
    H5O = H5OBindings(HDF5Lib);
    H5R = H5RBindings(HDF5Lib);
  }
}
