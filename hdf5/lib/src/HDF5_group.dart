import 'package:hdf5/src/HDF5_file.dart';
import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/HDF5_attributes.dart';
import 'package:hdf5/src/c_to_dart_calls/group.dart';
import 'package:hdf5/src/c_to_dart_calls/utility.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

class H5Group implements Finalizable {
  final H5File file;
  final String name;
  late final int groupId;

  late final AttributeMgr attr;
  late final List<String> groups;
  late final List<String> datasets;

  static final _finalizer = NativeFinalizer(HDF5Bindings().H5G.closePtr);

  H5Group(this.file, this.name) {
    Pointer<Uint8> namePtr = strToChar(name);
    groupId = HDF5Bindings().H5G.open(file.fileId, namePtr, H5P_DEFAULT);
    calloc.free(namePtr);
    attr = AttributeMgr(file, groupId);
    groups = getGroupItems(groupId, H5O_TYPE_GROUP);
    datasets = getGroupItems(groupId, H5O_TYPE_DATASET);

    _finalizer.attach(this, Pointer.fromAddress(groupId));
  }

  H5Group.rawInit(this.file, this.name, this.groupId)
      : attr = AttributeMgr(file, groupId),
        groups = getGroupItems(groupId, H5O_TYPE_GROUP),
        datasets = getGroupItems(groupId, H5O_TYPE_DATASET);

  dynamic operator [](String key) {
    if (isGroup(key)) {
      return file.openGroup("$name$key/");
    } else if (isDataset(key)) {
      return file.openDataset("$name$key");
    } else {
      throw "'$key' is not part of this group";
    }
  }

  bool isGroup(String name) {
    return groups.contains(name);
  }

  bool isDataset(String name) {
    return datasets.contains(name);
  }
}
