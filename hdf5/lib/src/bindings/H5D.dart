import 'dart:ffi';

import 'package:hdf5/src/utility/enum_utils.dart';
import 'package:hdf5/src/utility/logging.dart';

enum H5D_layout_t implements IndexEnum<H5D_layout_t> {
  LAYOUT_ERROR(-1, "Layout Error"),
  COMPACT(0, "Compact"),
  CONTIGUOUS(1, "Contiguous"),
  CHUNKED(2, "Chunked"),
  VIRTUAL(3, "Virtual"),
  NLAYERS(4, "NLayers");

  final int value;
  final String string;
  const H5D_layout_t(this.value, this.string);

  @override
  toString() => string;

  static H5D_layout_t fromIdx(int value) => IndexEnum.fromIdx(H5D_layout_t.values, value);
}

typedef H5Dopen_c = Int64 Function(
    Int64 loc_id, Pointer<Uint8> name, Int64 lapl_id);
typedef H5Dopen = int Function(int loc_id, Pointer<Uint8> name, int lapl_id);

typedef H5Dclose_c = Int64 Function(Int64 dset_id);
typedef H5Dclose = int Function(int dset_id);

// little hack to interpret int type as pointer. This is fine one 64 by systems.
typedef H5DcloseNative = Void Function(Pointer<void> attr_id);

typedef H5Dget_space_c = Int64 Function(Int64 dset_id);
typedef H5Dget_space = int Function(int dset_id);

typedef H5Dget_type_c = Int64 Function(Int64 dset_id);
typedef H5Dget_type = int Function(int dset_id);

typedef H5Dget_create_plist_c = Int64 Function(Int64 dset_id);
typedef H5Dget_create_plist = int Function(int dset_id);

typedef H5Dget_access_plist_c = Int64 Function(Int64 dset_id);
typedef H5Dget_access_plist = int Function(int dset_id);

typedef H5Dget_storage_size_c = Int64 Function(Int64 dset_id);
typedef H5Dget_storage_size = int Function(int dset_id);
typedef H5Dread_c = Int64 Function(Int64 dset_id, Int64 mem_type_id,
    Int64 mem_space_id, Int64 file_space_id, Int64 dxpl_id, Pointer buf);
typedef H5Dread = int Function(int dset_id, int mem_type_id, int mem_space_id,
    int file_space_id, int dxpl_id, Pointer buf);

typedef H5Drefresh_c = Int64 Function(Int64 dset_id);
typedef H5Drefresh = int Function(int dset_id);

class H5DBindings {
  final H5Dopen __open;
  final H5Dclose __close;

  final H5Dget_space __getSpace;
  final H5Dget_type __getType;
  final H5Dget_create_plist __getCreatePlist;
  final H5Dget_access_plist __getAccessPlist;

  final H5Dget_storage_size __getStorageSize;

  final H5Dread __read;
  final H5Drefresh __refresh;

  H5DBindings(DynamicLibrary HDF5Lib)
      : __open =
            HDF5Lib.lookup<NativeFunction<H5Dopen_c>>('H5Dopen2').asFunction(),
        __close =
            HDF5Lib.lookup<NativeFunction<H5Dclose_c>>('H5Dclose').asFunction(),
        __getSpace =
            HDF5Lib.lookup<NativeFunction<H5Dget_space_c>>('H5Dget_space')
                .asFunction(),
        __getType = HDF5Lib.lookup<NativeFunction<H5Dget_type_c>>('H5Dget_type')
            .asFunction(),
        __getCreatePlist =
            HDF5Lib.lookup<NativeFunction<H5Dget_create_plist_c>>(
                    'H5Dget_create_plist')
                .asFunction(),
        __getAccessPlist =
            HDF5Lib.lookup<NativeFunction<H5Dget_access_plist_c>>(
                    'H5Dget_access_plist')
                .asFunction(),
        __getStorageSize =
            HDF5Lib.lookup<NativeFunction<H5Dget_storage_size_c>>(
                    'H5Dget_storage_size')
                .asFunction(),
        __read =
            HDF5Lib.lookup<NativeFunction<H5Dread_c>>('H5Dread').asFunction(),
        __refresh = HDF5Lib.lookup<NativeFunction<H5Drefresh_c>>('H5Drefresh')
            .asFunction();

  int open(int loc_id, Pointer<Uint8> name, int lapl_id) {
    final id = __open(loc_id, name, lapl_id);
    logger.info('Opened dataset with the id $id');
    if (id < 0) {
      logger.severe('Failed to open dataset with name $name at the id $id');
      throw Exception("Failed to open dataset");
    }
    return id;
  }

  int close(int dset_id) {
    final status = __close(dset_id);
    logger.info('Closed dataset with id $dset_id');
    if (status < 0) {
      logger.severe(
          'Failed to close dataset with status $status and id $dset_id');
      throw Exception("Failed to close dataset");
    }
    return status;
  }

  int getSpace(int dset_id) {
    final space = __getSpace(dset_id);
    logger.fine('Got dataspace for dataset with id $dset_id');
    if (space < 0) {
      logger.severe('Failed to get dataspace for dataset with id $dset_id');
      throw Exception("Failed to get dataspace");
    }
    return space;
  }

  int getType(int dset_id) {
    final type = __getType(dset_id);
    if (type < 0) {
      logger.severe('Failed to get datatype for dataset with id $dset_id');
      throw Exception("Failed to get datatype");
    }
    return type;
  }

  int getCreatePlist(int dset_id) {
    final plist = __getCreatePlist(dset_id);
    if (plist < 0) {
      logger.severe(
          'Failed to get create property list for dataset with id $dset_id');
      throw Exception("Failed to get create property list");
    }
    return plist;
  }

  int getAccessPlist(int dset_id) {
    final plist = __getAccessPlist(dset_id);
    if (plist < 0) {
      logger.severe(
          'Failed to get access property list for dataset with id $dset_id');
      throw Exception("Failed to get access property list");
    }
    return plist;
  }

  int getStorageSize(int dset_id) {
    final size = __getStorageSize(dset_id);
    if (size < 0) {
      logger.severe(
          'Failed to get storage size for dataset with id $dset_id');
      throw Exception("Failed to get storage size");
    }
    return size;
  }

  int read(int dset_id, int mem_type_id, int mem_space_id, int file_space_id,
      int dxpl_id, Pointer buf) {
    final status =
        __read(dset_id, mem_type_id, mem_space_id, file_space_id, dxpl_id, buf);
    if (status < 0) {
      logger.severe('Failed to read dataset with id $dset_id');
      throw Exception("Failed to read dataset");
    }
    return status;
  }

  int refresh(int dset_id) {
    final status = __refresh(dset_id);
    logger.fine('Refreshed dataset with id $dset_id');
    if (status < 0) {
      logger.severe('Failed to refresh dataset with id $dset_id');
      throw Exception("Failed to refresh dataset");
    }
    return status;
  }
}