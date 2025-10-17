import 'package:hdf5/src/bindings/HDF5_bindings.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

class SpaceInfo {
  int rank;
  List<int> dim;
  List<int> maxDim;
  int spaceId;

  SpaceInfo(this.rank, this.dim, this.maxDim, {this.spaceId = -1});

  void dispose() {
    if (spaceId > 0) HDF5Bindings().H5S.close(spaceId);
  }
}

SpaceInfo getSpaceInfo(int spaceId) {
  HDF5Bindings HDF5lib = HDF5Bindings();

  int rank = HDF5lib.H5S.getSimpleExtentNdims(spaceId);

  List<int> dim = [];
  List<int> maxDim = [];
  if (rank > 0) {
    (dim, maxDim) = HDF5lib.H5S.getSimpleExtentDims(spaceId, rank);
  }

  return SpaceInfo(rank, dim, maxDim, spaceId: spaceId);
}
