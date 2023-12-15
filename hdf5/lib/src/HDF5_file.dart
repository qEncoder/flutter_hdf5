import 'package:hdf5/src/HDF5_dataset.dart';
import 'package:hdf5/src/HDF5_group.dart';
import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/c_to_dart_calls/utility.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

class H5File implements Finalizable {
  late final int fileId;

  static final _finalizer = NativeFinalizer(HDF5Bindings().H5F.closePtr);

  H5File.open(String filename) {
    Pointer<Uint8> namePtr = strToChar(filename);
    fileId = HDF5Bindings().H5F.open(namePtr, H5F_ACC_SWMR_READ, H5P_DEFAULT);
    calloc.free(namePtr);

    _finalizer.attach(this, Pointer.fromAddress(fileId));
  }

  H5Group get group {
    return openGroup("/");
  }

  H5Group openGroup(String name) {
    return H5Group(this, name);
  }

  H5Dataset openDataset(String name) {
    return H5Dataset(this, name);
  }
}
