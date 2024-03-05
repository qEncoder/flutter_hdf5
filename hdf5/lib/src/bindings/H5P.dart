import 'dart:ffi';

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

class H5PBindings {
  final H5Pcreate create;
  final H5Pclose close;
  final H5Pget_layout getLayout;
  final H5Pget_chunk getChunk;

  final H5Pget_chunk_cache getChunkCache;
  final H5Pset_chunk_cache setChunkCache;

  H5PBindings(DynamicLibrary HDF5Lib)
      : create = HDF5Lib.lookup<NativeFunction<h5pcreate_c>>('H5Pcreate').asFunction(),
        close = HDF5Lib.lookup<NativeFunction<h5pclose_c>>('H5Pclose').asFunction(),
        getLayout = HDF5Lib.lookup<NativeFunction<h5pget_layout_c>>('H5Pget_layout').asFunction(),
        getChunk = HDF5Lib.lookup<NativeFunction<h5pget_chunk_c>>('H5Pget_chunk').asFunction(),
        getChunkCache = HDF5Lib.lookup<NativeFunction<h5pget_chunk_cache_c>>('H5Pget_chunk_cache').asFunction(),
        setChunkCache = HDF5Lib.lookup<NativeFunction<h5pset_chunk_cache_c>>('H5Pset_chunk_cache').asFunction();       
}
