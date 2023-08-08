import 'dart:ffi';

const int H5S_ALL = 0; // /* (hid_t) */

typedef H5Sclose_c = Int64 Function(Int64 space_id);
typedef H5Sclose = int Function(int space_id);

typedef H5Sget_simple_extent_ndims_c = Int64 Function(Int64 space_id);
typedef H5Sget_simple_extent_ndims = int Function(int space_id);

typedef H5Sget_simple_extent_dims_c = Int64 Function(
    Int64 space_id, Pointer<Int64> dims, Pointer<Int64> maxdims);
typedef H5Sget_simple_extent_dims = int Function(
    int space_id, Pointer<Int64> dims, Pointer<Int64> maxdims);

class H5SBindings {
  final H5Sclose close;
  final Pointer<NativeFunction<Void Function(Pointer<Void>)>> closePtr;
  final H5Sget_simple_extent_ndims getSimpleExtentNdims;
  final H5Sget_simple_extent_dims getSimpleExtentDims;

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
                .asFunction();
}
