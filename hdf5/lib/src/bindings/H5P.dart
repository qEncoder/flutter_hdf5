import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:hdf5/src/bindings/H5FD.dart';
import 'package:hdf5/src/utility/logging.dart';
import 'package:hdf5/src/bindings/H5Z.dart';
import 'package:hdf5/src/bindings/H5D.dart';

typedef h5pcreate_c = Int64 Function(Int64 cls_id);
typedef H5Pcreate = int Function(int cls_id);

typedef h5pclose_c = Int64 Function(Int64 plist_id);
typedef H5Pclose = int Function(int plist_id);

typedef h5pget_layout_c = Int64 Function(Int64 plist_id);
typedef H5Pget_layout = int Function(int plist_id);

typedef h5pget_chunk_c = Int64 Function(
    Int64 plist_id, Int64 max_ndims, Pointer<Uint64> dim);
typedef H5Pget_chunk = int Function(
    int plist_id, int max_ndims, Pointer<Uint64> dim);

typedef h5pget_chunk_cache_c = Int64 Function(
    Int64 dapl_id,
    Pointer<Uint64> rdcc_nslots,
    Pointer<Uint64> rdcc_nbytes,
    Pointer<Double> rdcc_w0);
typedef H5Pget_chunk_cache = int Function(
    int dapl_id,
    Pointer<Uint64> rdcc_nslots,
    Pointer<Uint64> rdcc_nbytes,
    Pointer<Double> rdcc_w0);

typedef h5pset_chunk_cache_c = Int64 Function(
    Int64 dapl_id, Int64 rdcc_nslots, Int64 rdcc_nbytes, Double rdcc_w0);
typedef H5Pset_chunk_cache = int Function(
    int dapl_id, int rdcc_nslots, int rdcc_nbytes, double rdcc_w0);

typedef H5Pget_nfilters_c = Int64 Function(Int64 plist_id);
typedef H5Pget_nfilters = int Function(int plist_id);

typedef H5Pget_filter_c = Int64 Function( Int64 plist_id,
    Uint64 idx, Pointer<Uint64> flags, Pointer<Uint64> cd_nelmts,
    Pointer<Uint64> cd_values, Uint64 namelen, Pointer<Uint8> name,
    Pointer<Uint64> filter_config);
typedef H5Pget_filter = int Function(int plist_id,
    int idx, Pointer<Uint64> flags, Pointer<Uint64> cd_nelmts, 
    Pointer<Uint64> cd_values, int namelen, 
    Pointer<Uint8> name, Pointer<Uint64> filter_config);

typedef H5Pset_fapl_ros3_c = Int64 Function(
    Int64 fapl_id, Pointer<H5FD_ros3_fapl_t> fa);
typedef H5Pset_fapl_ros3 = int Function(
    int fapl_id, Pointer<H5FD_ros3_fapl_t> fa);

typedef H5Pset_fapl_ros3_token_c = Int64 Function(
    Int64 fapl_id, Pointer<Uint8> token);
typedef H5Pset_fapl_ros3_token = int Function(
    int fapl_id, Pointer<Uint8> token);

class FilterSettings{
  final H5Z_filter_t filterType;
  final List<int> __auxFilterValues;
  final double compressionRatio;

  FilterSettings(int filterTypeRaw, this.__auxFilterValues, this.compressionRatio):
    filterType = H5Z_filter_t.fromIdx(filterTypeRaw);
  
  Map<String, String> get compressionInfo{
    Map<String, String> info = {};
    if (filterType == H5Z_filter_t.DEFLATE){
      info['Compression level'] = __auxFilterValues[0].toString();
    }
    info['Compression ratio'] = compressionRatio.toString();
    return info;
  }
}

class H5PBindings {
  final H5Pcreate __create;
  final H5Pclose __close;
  final H5Pget_layout __getLayout;
  final H5Pget_chunk __getChunk;

  final H5Pget_chunk_cache __getChunkCache;
  final H5Pset_chunk_cache __setChunkCache;

  final H5Pget_nfilters __getNFilters;
  final H5Pget_filter __getFilter;

  final H5Pset_fapl_ros3 __setFaplRos3;
  final H5Pset_fapl_ros3_token __setFaplRos3Token;

  final int FILE_CREATE;
  final int FILE_ACCESS;
  final int DATASET_CREATE;
  final int DATASET_ACCESS;
  final int GROUP_CREATE;
  final int GROUP_ACCESS;
  final int ATTRIBUTE_CREATE;
  final int ATTRIBUTE_ACCESS;

  H5PBindings(DynamicLibrary HDF5Lib)
      : __create = HDF5Lib.lookup<NativeFunction<h5pcreate_c>>('H5Pcreate')
            .asFunction(),
        __close =
            HDF5Lib.lookup<NativeFunction<h5pclose_c>>('H5Pclose').asFunction(),
        __getLayout =
            HDF5Lib.lookup<NativeFunction<h5pget_layout_c>>('H5Pget_layout')
                .asFunction(),
        __getChunk =
            HDF5Lib.lookup<NativeFunction<h5pget_chunk_c>>('H5Pget_chunk')
                .asFunction(),
        __getChunkCache = HDF5Lib.lookup<NativeFunction<h5pget_chunk_cache_c>>(
                'H5Pget_chunk_cache')
            .asFunction(),
        __setChunkCache = HDF5Lib.lookup<NativeFunction<h5pset_chunk_cache_c>>(
                'H5Pset_chunk_cache')
            .asFunction(),
        __getNFilters = 
            HDF5Lib.lookup<NativeFunction<H5Pget_nfilters_c>>('H5Pget_nfilters')
                .asFunction(),
        __getFilter =
            HDF5Lib.lookup<NativeFunction<H5Pget_filter_c>>('H5Pget_filter2')
                .asFunction(),
        __setFaplRos3 = HDF5Lib.lookup<NativeFunction<H5Pset_fapl_ros3_c>>(
                'H5Pset_fapl_ros3')
            .asFunction(),
        __setFaplRos3Token =
            HDF5Lib.lookup<NativeFunction<H5Pset_fapl_ros3_token_c>>(
                    'H5Pset_fapl_ros3_token')
                .asFunction(),
        FILE_ACCESS = HDF5Lib.lookup<Int64>('H5P_CLS_FILE_ACCESS_ID_g').value,
        FILE_CREATE = HDF5Lib.lookup<Int64>('H5P_CLS_FILE_CREATE_ID_g').value,
        DATASET_CREATE =
            HDF5Lib.lookup<Int64>('H5P_CLS_DATASET_CREATE_ID_g').value,
        DATASET_ACCESS =
            HDF5Lib.lookup<Int64>('H5P_CLS_DATASET_ACCESS_ID_g').value,
        GROUP_CREATE = HDF5Lib.lookup<Int64>('H5P_CLS_GROUP_CREATE_ID_g').value,
        GROUP_ACCESS = HDF5Lib.lookup<Int64>('H5P_CLS_GROUP_ACCESS_ID_g').value,
        ATTRIBUTE_CREATE =
            HDF5Lib.lookup<Int64>('H5P_CLS_ATTRIBUTE_CREATE_ID_g').value,
        ATTRIBUTE_ACCESS =
            HDF5Lib.lookup<Int64>('H5P_CLS_ATTRIBUTE_ACCESS_ID_g').value;

  int create(int cls_id) {
    final id = __create(cls_id);
    if (id < 0) {
      logger.severe('Failed to create property list');
      throw Exception("Failed to create property list");
    }
    return id;
  }

  void close(int plist_id) {
    final status = __close(plist_id);
    if (status < 0) {
      logger.severe('Failed to close property list');
      throw Exception("Failed to close property list");
    }
  }

  H5D_layout_t getLayout(int plist_id) {
    final layout = __getLayout(plist_id);
    if (layout < 0) {
      logger.severe('Failed to get layout');
      throw Exception("Failed to get layout");
    }
    return H5D_layout_t.fromIdx(layout);
  }

  List<int> getChunkSize(int plist_id) {
    int max_ndims = 0;
    Pointer<Uint64> dim_null = nullptr;
    max_ndims = __getChunk(plist_id, max_ndims, dim_null);
    if (max_ndims < 0) {
      logger.severe('Failed to get chunk dimension');
      throw Exception("Failed to get chunk");
    }

    Pointer<Uint64> dim = calloc<Uint64>(max_ndims);
    final status = __getChunk(plist_id, max_ndims, dim);
    if (status < 0) {
      logger.severe('Failed to get chunk dimension');
      throw Exception("Failed to get chunk");
    }

    List<int> chunks = List.generate(max_ndims, (i) => dim[i]);
    calloc.free(dim);
    return chunks;
  }

  void getChunkCache(int dapl_id, Pointer<Uint64> rdcc_nslots,
      Pointer<Uint64> rdcc_nbytes, Pointer<Double> rdcc_w0) {
    final status = __getChunkCache(dapl_id, rdcc_nslots, rdcc_nbytes, rdcc_w0);
    if (status < 0) {
      logger.severe('Failed to get chunk cache');
      throw Exception("Failed to get chunk cache");
    }
  }

  void setChunkCache(
      int dapl_id, int rdcc_nslots, int rdcc_nbytes, double rdcc_w0) {
    final status = __setChunkCache(dapl_id, rdcc_nslots, rdcc_nbytes, rdcc_w0);
    if (status < 0) {
      logger.severe('Failed to set chunk cache');
      throw Exception("Failed to set chunk cache");
    }
  }

  int getNFilters(int plist_id) {
    final nfilters = __getNFilters(plist_id);
    if (nfilters < 0) {
      logger.severe('Failed to get number of filters for plist with id $plist_id');
      throw Exception("Failed to get number of filters");
    }
    return nfilters;
  }

  FilterSettings getFilter(int plist_id, int idx, double compressionRatio) {
    Pointer<Uint64> flags = calloc<Uint64>(1);
    Pointer<Uint64> cd_nelmts = calloc<Uint64>(1);
    Pointer<Uint64> cd_values_empty = nullptr;
    Pointer<Uint8> name = calloc<Uint8>(100);
    Pointer<Uint64> filter_config = calloc<Uint64>(1);

    int filterType = __getFilter(plist_id, idx, flags, cd_nelmts, cd_values_empty, 100, name, filter_config);
    if (filterType < 0) {
      logger.severe('Failed to get filter for plist with id $plist_id for $idx (empty cd_values)');
      throw Exception("Failed to get filter");
    }
    
    Pointer<Uint64> cd_values = calloc<Uint64>(cd_nelmts.value);
    if (cd_nelmts.value > 0) {
      filterType = __getFilter(plist_id, idx, flags, cd_nelmts, cd_values, 100, name, filter_config);
      if (filterType < 0) {
        logger.severe('Failed to get filter for plist with id $plist_id for $idx');
        throw Exception("Failed to get filter");
      }
    }
    
    FilterSettings filterSettings = FilterSettings(filterType, 
                                        List.generate(cd_nelmts.value, (i) => cd_values[i]),
                                        compressionRatio);
    calloc.free(flags);
    calloc.free(cd_nelmts);
    calloc.free(name);
    calloc.free(filter_config);
    if (cd_nelmts.value > 0) {
      calloc.free(cd_values);
    }

    return filterSettings;
  }

  void setFaplRos3(int fapl_id, Pointer<H5FD_ros3_fapl_t> fa) {
    final status = __setFaplRos3(fapl_id, fa);
    if (status < 0) {
      logger.severe('Failed to set ROS3 file access property list');
      throw Exception("Failed to set ROS3 file access property list");
    }
  }

  void setFaplRos3Token(int fapl_id, Pointer<Uint8> token) {
    final status = __setFaplRos3Token(fapl_id, token);
    if (status < 0) {
      logger.severe('Failed to set ROS3 token');
      throw Exception("Failed to set ROS3 token");
    }
  }
}
