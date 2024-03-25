import 'dart:ffi';

import 'package:hdf5/src/bindings/H5FD.dart';


typedef h5pcreate_c = Int64 Function(Int64 cls_id);
typedef H5Pcreate = int Function(int cls_id);

typedef h5pclose_c = Int64 Function(Int64 plist_id);
typedef H5Pclose = int Function(int plist_id);

typedef h5pget_layout_c = Int64 Function(Int64 plist_id);
typedef H5Pget_layout = int Function(int plist_id);

typedef h5pget_chunk_c = Int64 Function(
    Int64 plist_id, Int32 max_ndims, Pointer<Uint32> dim);
typedef H5Pget_chunk = int Function(int plist_id, int max_ndims, Pointer<Uint32> dim);

typedef h5pget_chunk_cache_c = Int64 Function(
    Int64 dapl_id, Pointer<Uint64> rdcc_nslots, Pointer<Uint64> rdcc_nbytes, Pointer<Double> rdcc_w0);
typedef H5Pget_chunk_cache = int Function(
    int dapl_id, Pointer<Uint64> rdcc_nslots, Pointer<Uint64> rdcc_nbytes, Pointer<Double> rdcc_w0);

typedef h5pset_chunk_cache_c = Int64 Function(
    Int64 dapl_id, Int64 rdcc_nslots, Int64 rdcc_nbytes, Double rdcc_w0);
typedef H5Pset_chunk_cache = int Function(
    int dapl_id, int rdcc_nslots, int rdcc_nbytes, double rdcc_w0);

typedef H5Pset_fapl_ros3_c = Int64 Function(Int64 fapl_id, Pointer<H5FD_ros3_fapl_t> fa);
typedef H5Pset_fapl_ros3 = int Function(int fapl_id, Pointer<H5FD_ros3_fapl_t> fa);

typedef H5Pset_fapl_ros3_token_c = Int64 Function(Int64 fapl_id, Pointer<Uint8> token);
typedef H5Pset_fapl_ros3_token = int Function(int fapl_id, Pointer<Uint8> token);

class H5PBindings {
  final H5Pcreate create;
  final H5Pclose close;
  final H5Pget_layout getLayout;
  final H5Pget_chunk getChunk;

  final H5Pget_chunk_cache getChunkCache;
  final H5Pset_chunk_cache setChunkCache;

  final H5Pset_fapl_ros3 setFaplRos3;
  final H5Pset_fapl_ros3_token setFaplRos3Token;

  final int FILE_CREATE;
  final int FILE_ACCESS;
  final int DATASET_CREATE;
  final int DATASET_ACCESS;
  final int GROUP_CREATE;
  final int GROUP_ACCESS;
  final int ATTRIBUTE_CREATE;
  final int ATTRIBUTE_ACCESS;

  H5PBindings(DynamicLibrary HDF5Lib)
      : create = HDF5Lib.lookup<NativeFunction<h5pcreate_c>>('H5Pcreate').asFunction(),
        close = HDF5Lib.lookup<NativeFunction<h5pclose_c>>('H5Pclose').asFunction(),
        getLayout = HDF5Lib.lookup<NativeFunction<h5pget_layout_c>>('H5Pget_layout').asFunction(),
        getChunk = HDF5Lib.lookup<NativeFunction<h5pget_chunk_c>>('H5Pget_chunk').asFunction(),
        getChunkCache = HDF5Lib.lookup<NativeFunction<h5pget_chunk_cache_c>>('H5Pget_chunk_cache').asFunction(),
        setChunkCache = HDF5Lib.lookup<NativeFunction<h5pset_chunk_cache_c>>('H5Pset_chunk_cache').asFunction(),
        setFaplRos3 = HDF5Lib.lookup<NativeFunction<H5Pset_fapl_ros3_c>>('H5Pset_fapl_ros3').asFunction(),
        setFaplRos3Token = HDF5Lib.lookup<NativeFunction<H5Pset_fapl_ros3_token_c>>('H5Pset_fapl_ros3_token').asFunction(),
        FILE_ACCESS = HDF5Lib.lookup<Int64>('H5P_CLS_FILE_ACCESS_ID_g').value,
        FILE_CREATE = HDF5Lib.lookup<Int64>('H5P_CLS_FILE_CREATE_ID_g').value,
        DATASET_CREATE = HDF5Lib.lookup<Int64>('H5P_CLS_DATASET_CREATE_ID_g').value,
        DATASET_ACCESS = HDF5Lib.lookup<Int64>('H5P_CLS_DATASET_ACCESS_ID_g').value,
        GROUP_CREATE = HDF5Lib.lookup<Int64>('H5P_CLS_GROUP_CREATE_ID_g').value,
        GROUP_ACCESS = HDF5Lib.lookup<Int64>('H5P_CLS_GROUP_ACCESS_ID_g').value,
        ATTRIBUTE_CREATE = HDF5Lib.lookup<Int64>('H5P_CLS_ATTRIBUTE_CREATE_ID_g').value,
        ATTRIBUTE_ACCESS = HDF5Lib.lookup<Int64>('H5P_CLS_ATTRIBUTE_ACCESS_ID_g').value;
}
