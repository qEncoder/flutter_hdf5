import 'package:hdf5/src/bindings/HDF5_bindings.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

class SpaceInfo implements Finalizable {
  int rank;
  List<int> dim;
  List<int> maxDim;
  int spaceId;

  static final _finalizer = NativeFinalizer(HDF5Bindings().H5S.closePtr);

  SpaceInfo(this.rank, this.dim, this.maxDim, {this.spaceId = -1}) {
    if (spaceId != -1) {
      _finalizer.attach(this, Pointer.fromAddress(spaceId));
    }
  }
}

SpaceInfo getSpaceInfo(int spaceId) {
  HDF5Bindings HDF5lib = HDF5Bindings();

  int rank = HDF5lib.H5S.getSimpleExtentNdims(spaceId);

  List<int> dim = [];
  List<int> maxDim = [];
  if (rank > 0) {
    Pointer<Int64> dimPtr = calloc.allocate<Int64>(rank);
    Pointer<Pointer<Int64>> dimPtrPtr = Pointer.fromAddress(dimPtr.address);
    Pointer<Int64> maxDimPtr = calloc.allocate<Int64>(rank);
    Pointer<Pointer<Int64>> maxDimPtrPtr = Pointer.fromAddress(dimPtr.address);
    HDF5lib.H5S.getSimpleExtentDims(spaceId, dimPtrPtr, maxDimPtrPtr);

    for (var i = 0; i < rank; i++) {
      dim.add(dimPtr[i]);
      maxDim.add(dimPtr[i]);
    }
    calloc.free(dimPtr);
    calloc.free(maxDimPtr);
  }

  return SpaceInfo(rank, dim, maxDim, spaceId: spaceId);
}
