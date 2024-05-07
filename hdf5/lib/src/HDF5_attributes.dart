import 'package:hdf5/src/HDF5_file.dart';
import 'package:hdf5/src/c_to_dart_calls/attributes.dart';

class AttributeMgr extends Iterable {
  final H5File file;
  final int parentLocId;  
  final List<String> attrNames;

  AttributeMgr(this.file, this.parentLocId)
      : attrNames = getAttrNames(parentLocId);

  List<String> get keys => attrNames;
  List<dynamic> get values => attrNames.map((e) => readAttr(file, parentLocId, e)).toList();

  @override
  Iterator<MapEntry<String, dynamic>> get iterator => __AttributeMgrIterator(this);

  dynamic operator [](String key) {
    if (attrNames.contains(key)) {
      return readAttr(file, parentLocId, key);
    } else {
      throw 'AttributeError : $key does not exist.';
    }
  }
}

class __AttributeMgrIterator implements Iterator<MapEntry<String, dynamic>> {
  final AttributeMgr _attrMgr;
  int __index = -1;

  __AttributeMgrIterator(this._attrMgr);

  @override
  bool moveNext() {
    if (__index + 1 < _attrMgr.keys.length) return true;
    return false;
  }

  @override
  MapEntry<String, dynamic> get current {
    __index++;
    if (__index < _attrMgr.keys.length) {
      return MapEntry(_attrMgr.keys[__index], readAttr(_attrMgr.file, _attrMgr.parentLocId, _attrMgr.keys[__index]));
    } else {
      throw 'IndexError : Index out of range.';
    }
  }
}