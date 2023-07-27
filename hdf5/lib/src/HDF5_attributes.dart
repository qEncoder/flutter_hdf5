import 'dart:ffi';

import 'package:hdf5/src/HDF5_file.dart';
import 'package:hdf5/src/c_to_dart_calls/attributes.dart';

class AttributeMgr implements Finalizable {
  final H5File file;
  final int parentLocId;

  final List<String> attrNames;

  AttributeMgr(this.file, this.parentLocId)
      : attrNames = getAttrNames(parentLocId);

  List<String> get keys => attrNames;

  dynamic operator [](String key) {
    if (attrNames.contains(key)) {
      return readAttr(file, parentLocId, key);
    } else {
      throw 'AttributeError : $key does not exist.';
    }
  }
}
