import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/HDF5_attributes.dart';
import 'package:hdf5/src/c_to_dart_calls/space_info.dart';
import 'package:hdf5/src/c_to_dart_calls/utility.dart';
import 'package:hdf5/src/c_to_dart_calls/dataset.dart';
import 'package:hdf5/src/HDF5_file.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:hdf5/src/utility/logging.dart';

class H5Dataset {
  final H5File file;
  final String fullName;
  final String name;

  late int ndim;
  late List<int> shape;

  late final int __datasetId;

  bool __closed = false;
  get datasetId => (__closed) ? -1 : __datasetId;

  late final AttributeMgr attr;

  H5Dataset(this.file, this.fullName) : name = fullName.split("/").last {
    logger.info("Opening dataset $fullName in file ${file.fileName}");
    Pointer<Uint8> namePtr = strToChar(fullName);

    __datasetId = HDF5Bindings().H5D.open(file.fileId, namePtr, H5P_DEFAULT);
    calloc.free(namePtr);

    attr = AttributeMgr(file, datasetId);

    int spaceId = HDF5Bindings().H5D.getSpace(datasetId);
    SpaceInfo spaceInfo = getSpaceInfo(spaceId);
    ndim = spaceInfo.rank;
    shape = spaceInfo.dim;
    spaceInfo.dispose();
    file.children.add(this);
  }

  void close() {
    if (__closed) return;

    __closed = true;
    HDF5Bindings().H5D.close(__datasetId);
  }

  void refresh() {
    HDF5Bindings().H5D.refresh(datasetId);

    int spaceId = HDF5Bindings().H5D.getSpace(datasetId);
    SpaceInfo spaceInfo = getSpaceInfo(spaceId);
    ndim = spaceInfo.rank;
    shape = spaceInfo.dim;
    spaceInfo.dispose();
  }

  dynamic getData() {
    return readData(datasetId, []);
  }

  dynamic operator [](dynamic idx) {
    return readData(datasetId, idx);
  }

  @override
  String toString() {
    return "Dataset :: $name";
  }
}
