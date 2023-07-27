import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/c_to_dart_calls/utility.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

List<String> getGroupItems(int locId, itemType) {
  HDF5Bindings HDF5lib = HDF5Bindings();
  List<String> groupNames = [];

  Pointer<Int64> n_groups = calloc.allocate<Int64>(1);
  HDF5lib.H5G.getNumObjs(locId, n_groups);
  int nGroups = n_groups.value;
  calloc.free(n_groups);

  Pointer<Uint8> grp_name = strToChar('.');
  for (var i = 0; i < nGroups; i++) {
    Pointer<Pointer<Uint8>> namePtr = Pointer.fromAddress(0);

    int strSize = HDF5lib.H5L.getNameByIdx(locId, grp_name, H5_INDEX_NAME,
        H5_ITER_INC, i, namePtr, 0, H5P_DEFAULT);

    Pointer<Uint8> name = calloc.allocate(strSize + 1);
    namePtr = Pointer.fromAddress(name.address);

    HDF5lib.H5L.getNameByIdx(locId, grp_name, H5_INDEX_NAME, H5_ITER_INC, i,
        namePtr, strSize + 1, H5P_DEFAULT);

    final Pointer<H5O_info_t> oInfo = calloc<H5O_info_t>();
    HDF5lib.H5O.getInfoByIdx(locId, grp_name, H5_INDEX_NAME, H5_ITER_INC, i,
        oInfo, H5O_INFO_BASIC, H5P_DEFAULT);

    if (oInfo.ref.type == itemType) {
      String grpName = charToString(name);
      groupNames.add(grpName);
    }

    calloc.free(name);
    calloc.free(oInfo);
  }
  calloc.free(grp_name);
  return groupNames;
}
