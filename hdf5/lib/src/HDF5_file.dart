import 'package:hdf5/src/HDF5_dataset.dart';
import 'package:hdf5/src/HDF5_group.dart';
import 'package:hdf5/src/bindings/H5FD.dart';
import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/c_to_dart_calls/utility.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:hdf5/src/utility/logging.dart';

class H5File {
  final String fileName;
  late final int __fileId;

  bool __closed = false;
  List children = [];

  get fileId => (__closed) ? -1 : __fileId;

  H5File.open(this.fileName)
      : __fileId =
            HDF5Bindings().H5F.open(fileName, H5F_ACC_SWMR_READ, H5P_DEFAULT);

  H5File.openROS3(
      String url, String aws_region, String secret_id, String secret_key,
      {String token = ""})
      : fileName = url {
    logger.info("Opening file using ROS3: $url");
    HDF5Bindings b = HDF5Bindings();

    int fapl_id = b.H5P.create(b.H5P.FILE_ACCESS);

    Pointer<H5FD_ros3_fapl_t> fa = calloc<H5FD_ros3_fapl_t>(1);
    fa[0].version = 1;
    fa[0].authenticate = true;
    strToArray(aws_region, fa[0].aws_region, 32 + 1);
    strToArray(secret_id, fa[0].secret_id, 128 + 1);
    strToArray(secret_key, fa[0].secret_key, 128 + 1);

    b.H5P.setFaplRos3(fapl_id, fa);

    if (token.isNotEmpty) {
      Pointer<Uint8> tokenPtr = strToChar(token);
      b.H5P.setFaplRos3Token(fapl_id, tokenPtr);
      calloc.free(tokenPtr);
    }

    __fileId = HDF5Bindings().H5F.open(url, H5F_ACC_RDONLY, fapl_id);
    calloc.free(fa);
    b.H5P.close(fapl_id);
  }

  void close() {
    if (__closed) return;

    for (var child in children.reversed) {
      child.close();
    }
    __closed = true;
    HDF5Bindings().H5F.close(__fileId);
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
