import 'package:hdf5/src/HDF5_dataset.dart';
import 'package:hdf5/src/HDF5_group.dart';
import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/c_to_dart_calls/utility.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

class H5File implements Finalizable {
  final String fileName
  late final int fileId;

  static final _finalizer = NativeFinalizer(HDF5Bindings().H5F.closePtr);

  H5File.open(this.fileName) {
    Pointer<Uint8> namePtr = strToChar(fileName);
    fileId = HDF5Bindings().H5F.open(namePtr, H5F_ACC_RDONLY, H5P_DEFAULT);
    calloc.free(namePtr);
    print("file opened with the following ID $fileId");

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
