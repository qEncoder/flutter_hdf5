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
        H5O_INFO_ALL,
        H5O_TYPE_UNKNOWN,
        H5O_TYPE_GROUP,
        H5O_TYPE_DATASET,
        H5O_TYPE_NAMED_DATATYPE,
        H5O_TYPE_MAP,
        H5O_TYPE_NTYPES;
export 'H5T.dart'
    show
        H5T_class_t,
        H5T_NO_CLASS,
        H5T_INTEGER,
        H5T_FLOAT,
        H5T_TIME,
        H5T_STRING,
        H5T_BITFIELD,
        H5T_OPAQUE,
        H5T_COMPOUND,
        H5T_REFERENCE,
        H5T_ENUM,
        H5T_VLEN,
        H5T_ARRAY;
export 'H5S.dart' show H5S_ALL;
export 'H5R.dart'
    show H5R_BADTYPE, H5R_OBJECT, H5R_DATASET_REGION, H5R_MAXTYPE, H5R_type_t;

import 'H5.dart';
import 'H5A.dart';
import 'H5D.dart';
import 'H5F.dart';
import 'H5G.dart';
import 'H5L.dart';
import 'H5S.dart';
import 'H5T.dart';
import 'H5O.dart';
import 'H5R.dart';

class H5RBindings {
  final H5Rdereference deReference;
  final H5Rget_name getName;
  final H5Rget_obj_type getObjType;

  H5RBindings(DynamicLibrary HDF5Lib)
      : deReference =
            HDF5Lib.lookup<NativeFunction<H5Rdereference_c>>('H5Rdereference2')
                .asFunction(),
        getName = HDF5Lib.lookup<NativeFunction<H5Rget_name_c>>('H5Rget_name')
            .asFunction(),
        getObjType = HDF5Lib.lookup<NativeFunction<H5Rget_obj_type_c>>(
                'H5Rget_obj_type2')
            .asFunction();
}

class HDF5Bindings {
  static final HDF5Bindings __instance = HDF5Bindings.__new__();
  late final H5Bindings H5;
  late final H5ABindings H5A;
  late final H5DBindings H5D;
  late final H5FBindings H5F;
  late final H5GBindings H5G;
  late final H5LBindings H5L;
  late final H5SBindings H5S;
  late final H5TBindings H5T;
  late final H5OBindings H5O;
  late final H5RBindings H5R;

  factory HDF5Bindings() {
    return __instance;
  }

  HDF5Bindings.__new__() {
    String libraryPath;

    libraryPath = 'libhdf5.so';
    if (Platform.isMacOS) {
      libraryPath = 'libHDF5.dylib';
    } else if (Platform.isWindows) {
      libraryPath = 'HDF5.dll';
    }

    final DynamicLibrary HDF5Lib = DynamicLibrary.open(libraryPath);

    H5 = H5Bindings(HDF5Lib);
    H5A = H5ABindings(HDF5Lib);
    H5D = H5DBindings(HDF5Lib);
    H5F = H5FBindings(HDF5Lib);
    H5G = H5GBindings(HDF5Lib);
    H5L = H5LBindings(HDF5Lib);
    H5S = H5SBindings(HDF5Lib);
    H5T = H5TBindings(HDF5Lib);
    H5O = H5OBindings(HDF5Lib);
    H5R = H5RBindings(HDF5Lib);
  }
}
