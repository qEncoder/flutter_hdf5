import 'package:hdf5/src/bindings/HDF5_bindings.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

List<String> getGroupItems(int locId, itemType) {
  HDF5Bindings HDF5lib = HDF5Bindings();
  List<String> groupNames = [];

  int nGroups = HDF5lib.H5G.getNumObjs(locId);

  for (var i = 0; i < nGroups; i++) {
    final Pointer<H5O_info_t> oInfo = calloc<H5O_info_t>();
    HDF5lib.H5O.getInfoByIdx(locId, i, oInfo);
   
    if (oInfo.ref.type == itemType) {
      String name = HDF5lib.H5L.getNameByIdx(locId, i);
      // fix for irritating windows error, neglect any dataset ending with _DOUBLE_COMPLEX_TYPE
      if (!name.endsWith("_DOUBLE_COMPLEX_TYPE")) {
        groupNames.add(name);
      }
    }

    calloc.free(oInfo);
  }
  return groupNames;
}
