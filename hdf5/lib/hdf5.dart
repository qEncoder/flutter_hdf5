import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'dart:io';

import 'dart:convert' show utf8;

import 'package:path/path.dart' as path;
import 'dart:io' show Platform, Directory;

var a = Platform.isMacOS;

typedef H5LTget_attribute_ndims = Int64 Function(
    Int64, Pointer<Uint8>, Pointer<Uint8>, Pointer<Int>);
typedef H5LTGetAttributeNdims = int Function(
    int, Pointer<Uint8>, Pointer<Uint8>, Pointer<Int>);

class ffiHDF5 {
  static late final DynamicLibrary HDF5API;

  static bool __initialized__ = false;

  static late H5LTGetAttributeNdims _H5LTget_attribute_ndims;

  static void _initialize() {
    String libraryPath = path.join(
        Directory.current.path, '../libc/linux/', 'libhdf5_serial.so');
    if (Platform.isMacOS) {
      libraryPath = path.join(
          Directory.current.path, '../libc/MacOS/', 'libhdf5_serial.dylib');
    } else if (Platform.isWindows) {
      libraryPath = path.join('../libc/Windows/', 'libhdf5_serial.dll');
    }

    HDF5API = DynamicLibrary.open(libraryPath);

    _H5LTget_attribute_ndims = HDF5API
        .lookup<NativeFunction<H5LTget_attribute_ndims>>(
            'H5LTget_attribute_ndims')
        .asFunction();

    __initialized__ = true;
  }

  int H5TGetAttributeNdims(int locId, String attrName) {
    Pointer<Uint8> objName = stringToPointer(".");
    Pointer<Uint8> attr_name = stringToPointer(attrName);
    Pointer<Int> rank = calloc<Int>(1);

    _H5LTget_attribute_ndims(locId, objName, attr_name, rank);
    int nAttr = rank.value;

    calloc.free(objName);
    calloc.free(attr_name);
    calloc.free(rank);

    return nAttr;
  }
}

Pointer<Uint8> stringToPointer(String str) {
  Pointer<Uint8> stringPointer = calloc<Uint8>(str.length + 1);
  List<int> stringList = utf8.encode(str);
  Uint8List stringByteList = Uint8List.fromList(stringList);

  for (int i = 0; i < stringByteList.length; i++) {
    stringPointer[i] = stringByteList[i];
  }

  return stringPointer;
}
