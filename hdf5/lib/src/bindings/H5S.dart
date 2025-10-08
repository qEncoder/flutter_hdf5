import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:hdf5/src/utility/enum_utils.dart';
import 'package:hdf5/src/utility/logging.dart';
import 'package:numd/numd.dart';
import 'package:numd/src/base/ndarray.dart' show intListToCArray;

const int H5S_ALL = 0; // /* (hid_t) */

enum H5S_seloper_t implements IndexEnum<H5S_seloper_t> {
  NOOP(-1, "NOOP"),
  SET(0, "SET"),
  OR(1, "OR"),
  AND(2, "AND"),
  XOR(3, "XOR"),
  NOTB(4, "NOTB"),
  NOTA(5, "NOTA"),
  APPEND(6, "APPEND"),
  PREPEND(7, "PREPEND"),
  INVALID(8, "INVALID");


  final int value;
  final String string;
  const H5S_seloper_t(this.value, this.string);
}

typedef H5Sclose_c = Int64 Function(Int64 space_id);
typedef H5Sclose = int Function(int space_id);

typedef H5Sget_simple_extent_ndims_c = Int64 Function(Int64 space_id);
typedef H5Sget_simple_extent_ndims = int Function(int space_id);

typedef H5Sget_simple_extent_dims_c = Int64 Function(
    Int64 space_id, Pointer<Int64> dims, Pointer<Int64> maxdims);
typedef H5Sget_simple_extent_dims = int Function(
    int space_id, Pointer<Int64> dims, Pointer<Int64> maxdims);

typedef H5Screate_simple_c = Int64 Function(
    Int64 rank, Pointer<Int64> dims, Pointer<Int64> maxdims);
typedef H5Screate_simple = int Function(
    int rank, Pointer<Int64> dims, Pointer<Int64> maxdims);

typedef H5Sselect_hyperslab_c = Int64 Function(
    Int64 space_id,
    Int32 op,
    Pointer<Int64> start,
    Pointer<Int64> stride,
    Pointer<Int64> count,
    Pointer<Int64> block);
typedef H5Sselect_hyperslab = int Function(
    int space_id,
    int op,
    Pointer<Int64> start,
    Pointer<Int64> stride,
    Pointer<Int64> count,
    Pointer<Int64> block);

class H5SBindings {
  final H5Sclose __close;
  final H5Sget_simple_extent_ndims __getSimpleExtentNdims;
  final H5Sget_simple_extent_dims __getSimpleExtentDims;
  final H5Screate_simple __createSimple;
  final H5Sselect_hyperslab __selectHyperslab;

  H5SBindings(DynamicLibrary HDF5Lib)
      : __close =
            HDF5Lib.lookup<NativeFunction<H5Sclose_c>>('H5Sclose').asFunction(),
        __getSimpleExtentNdims =
            HDF5Lib.lookup<NativeFunction<H5Sget_simple_extent_ndims_c>>(
                    'H5Sget_simple_extent_ndims')
                .asFunction(),
        __getSimpleExtentDims =
            HDF5Lib.lookup<NativeFunction<H5Sget_simple_extent_dims_c>>(
                    'H5Sget_simple_extent_dims')
                .asFunction(),
        __createSimple = HDF5Lib.lookup<NativeFunction<H5Screate_simple_c>>(
                'H5Screate_simple')
            .asFunction(),
        __selectHyperslab =
            HDF5Lib.lookup<NativeFunction<H5Sselect_hyperslab_c>>(
                    'H5Sselect_hyperslab')
                .asFunction();

  void close(int space_id) {
    final status = __close(space_id);
    if (status < 0) {
      logger.severe('Failed to close dataspace');
      throw Exception('Failed to close space');
    }
  }

  int getSimpleExtentNdims(int space_id) {
    final rank = __getSimpleExtentNdims(space_id);
    if (rank < 0) {
      logger.severe('Failed to get rank of dataspace');
      throw Exception('Failed to get rank of dataspace');
    }
    return rank;
  }

  (List<int>, List<int>) getSimpleExtentDims(int space_id, int rank) {
    Pointer<Int64> dimPtr = calloc<Int64>(rank);
    Pointer<Int64> maxdimPtr = calloc<Int64>(rank);

    final status = __getSimpleExtentDims(space_id, dimPtr, maxdimPtr);
    if (status < 0) {
      calloc.free(dimPtr);
      calloc.free(maxdimPtr);
      logger.severe('Failed to get dataspace dimensions');
      throw Exception('Failed to get dataspace dimensions');
    }

    List<int> dim = List.generate(rank, (index) => dimPtr[index]);
    List<int> maxDim = List.generate(rank, (index) => maxdimPtr[index]);

    calloc.free(dimPtr);
    calloc.free(maxdimPtr);
    return (dim, maxDim);
  }

  int createSimple(List<int> dims) {
    Pointer<Int64> dimMS = intListToCArray(dims);
    final space_id = __createSimple(dims.length, dimMS, nullptr);
    calloc.free(dimMS);
    if (space_id < 0) {
      logger.severe('Failed to create dataspace');
      throw Exception('Failed to create dataspace');
    }
    return space_id;
  }

  void selectHyperslab(int space_id, List<int> start, List<int> count) {
    Pointer<Int64> startPtr = intListToCArray(start);
    Pointer<Int64> countPtr = intListToCArray(count);

    final status = __selectHyperslab(
        space_id, H5S_seloper_t.SET.value, startPtr, nullptr, countPtr, nullptr);

    calloc.free(startPtr);
    calloc.free(countPtr);

    if (status < 0) {
      logger.severe('Failed to select hyperslab');
      throw Exception('Failed to select hyperslab');
    }
  }
}
