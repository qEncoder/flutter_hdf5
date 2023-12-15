import 'dart:ffi';

const int H5S_ALL = 0; // /* (hid_t) */

// H5S_seloper_t
const int H5S_SELECT_NOOP = -1;
const int H5S_SELECT_SET = 0;
const int H5S_SELECT_OR = 1;
const int H5S_SELECT_AND = 2;
const int H5S_SELECT_XOR = 3;
const int H5S_SELECT_NOTB = 4;
const int H5S_SELECT_NOTA = 5;
const int H5S_SELECT_APPEND = 6;
const int H5S_SELECT_PREPEND = 7;
const int H5S_SELECT_INVALID = 8;

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
  final H5Sclose close;
  final Pointer<NativeFunction<Void Function(Pointer<Void>)>> closePtr;
  final H5Sget_simple_extent_ndims getSimpleExtentNdims;
  final H5Sget_simple_extent_dims getSimpleExtentDims;
  final H5Screate_simple createSimple;
  final H5Sselect_hyperslab selectHyperslab;

  H5SBindings(DynamicLibrary HDF5Lib)
      : close =
            HDF5Lib.lookup<NativeFunction<H5Sclose_c>>('H5Sclose').asFunction(),
        closePtr = HDF5Lib.lookup<NativeFunction<Void Function(Pointer<Void>)>>(
            'H5Sclose'),
        getSimpleExtentNdims =
            HDF5Lib.lookup<NativeFunction<H5Sget_simple_extent_ndims_c>>(
                    'H5Sget_simple_extent_ndims')
                .asFunction(),
        getSimpleExtentDims =
            HDF5Lib.lookup<NativeFunction<H5Sget_simple_extent_dims_c>>(
                    'H5Sget_simple_extent_dims')
                .asFunction(),
        createSimple = HDF5Lib.lookup<NativeFunction<H5Screate_simple_c>>(
                'H5Screate_simple')
            .asFunction(),
        selectHyperslab = HDF5Lib.lookup<NativeFunction<H5Sselect_hyperslab_c>>(
                'H5Sselect_hyperslab')
            .asFunction();
}
