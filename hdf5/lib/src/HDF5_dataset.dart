import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/HDF5_attributes.dart';
import 'package:hdf5/src/c_to_dart_calls/space_info.dart';
import 'package:hdf5/src/c_to_dart_calls/utility.dart';
import 'package:hdf5/src/c_to_dart_calls/dataset.dart';
import 'package:hdf5/src/HDF5_file.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

class H5Dataset implements Finalizable {
  final H5File file;
  final String _name;
  final String name;

  late final int ndim;
  late final List<int> shape;

  late final int datasetId;

  late final AttributeMgr attr;

  static final _finalizer = NativeFinalizer(HDF5Bindings().H5D.closePtr);

  H5Dataset(this.file, this._name) : name = _name.split("/").last {
    Pointer<Uint8> namePtr = strToChar(_name);
    datasetId = HDF5Bindings().H5D.open(file.fileId, namePtr, H5P_DEFAULT);
    print("creating dataset $name with id:: ${datasetId}");

    attr = AttributeMgr(file, datasetId);

    int spaceId = HDF5Bindings().H5D.getSpace(datasetId);
    SpaceInfo spaceInfo = getSpaceInfo(spaceId);
    ndim = spaceInfo.rank;
    shape = spaceInfo.dim;
    spaceInfo.dispose();

    _finalizer.attach(this, Pointer.fromAddress(datasetId));
  }

  H5Dataset.rawInit(this.file, this._name, this.datasetId)
      : attr = AttributeMgr(file, datasetId),
        name = _name.split("/").last {
    print("creating dataset $_name with id:: ${datasetId} (RAW INIT)");

    Pointer<Int64> dsID = calloc<Int64>(1);
    dsID.value = datasetId;
    _finalizer.attach(this, dsID.cast());
  }

  dynamic getData() {
    return readData(datasetId);
  }

  @override
  String toString() {
    return "Dataset :: $name";
  }
}
