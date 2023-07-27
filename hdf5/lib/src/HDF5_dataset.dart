import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/HDF5_attributes.dart';
import 'package:hdf5/src/c_to_dart_calls/utility.dart';
import 'package:hdf5/src/c_to_dart_calls/dataset.dart';
import 'package:hdf5/src/HDF5_file.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

class H5Dataset implements Finalizable {
  final H5File file;
  final String name;
  late final int datasetId;

  late final AttributeMgr attr;

  static final _finalizer = NativeFinalizer(HDF5Bindings().H5D.closePtr);

  H5Dataset(this.file, this.name) {
    Pointer<Uint8> namePtr = strToChar(name);
    datasetId = HDF5Bindings().H5D.open(file.fileId, namePtr, H5P_DEFAULT);
    calloc.free(namePtr);
    attr = AttributeMgr(file, datasetId);

    _finalizer.attach(this, Pointer.fromAddress(datasetId));
  }

  H5Dataset.rawInit(this.file, this.name, this.datasetId)
      : attr = AttributeMgr(file, datasetId);

  dynamic getData() {
    readData(datasetId);
  }

  @override
  String toString() {
    return "Dataset $name";
  }
}
