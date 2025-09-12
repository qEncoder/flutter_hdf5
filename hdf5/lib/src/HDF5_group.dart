import 'package:hdf5/src/HDF5_file.dart';
import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/HDF5_attributes.dart';
import 'package:hdf5/src/c_to_dart_calls/group.dart';
import 'package:hdf5/src/c_to_dart_calls/utility.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:hdf5/src/utility/logging.dart';

class H5Group {
  final H5File file;
  final String name;
  late final int __groupId;

  bool __closed = false;

  late final AttributeMgr attr;
  late final List<String> groups;
  late final List<String> datasets;

  get groupId => (__closed) ? -1 : __groupId;

  H5Group(this.file, this.name) {
    logger.info("Opening group $name in file ${file.fileName}");
    Pointer<Uint8> namePtr = strToChar(name);
    __groupId = HDF5Bindings().H5G.open(file.fileId, namePtr, H5P_DEFAULT);

    calloc.free(namePtr);
    attr = AttributeMgr(file, groupId);
    groups = getGroupItems(groupId, H5O_type_t.GROUP.value);
    datasets = getGroupItems(groupId, H5O_type_t.DATASET.value);
    file.children.add(this);
  }

  void close() {
    if (__closed) return;

    __closed = true;
    HDF5Bindings().H5G.close(__groupId);
  }

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
