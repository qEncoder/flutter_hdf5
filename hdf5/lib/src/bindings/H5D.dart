import 'dart:ffi';

const int H5D_LAYOUT_ERROR = -1;
const int H5D_COMPACT = 0;
const int H5D_CONTIGUOUS = 1;
const int H5D_CHUNKED = 2;
const int H5D_VIRTUAL = 3;
const int H5D_NLAYOUTS = 4;

const Map<int, String> H5D_layout_t = {
  -1: "H5D_LAYOUT_ERROR",
  0: "H5D_COMPACT",
  1: "H5D_CONTIGUOUS",
  2: "H5D_CHUNKED",
  3: "H5D_VIRTUAL",
  4: "H5D_NLAYOUTS"
};

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
        __read =
            HDF5Lib.lookup<NativeFunction<H5Dread_c>>('H5Dread').asFunction(),
        __refresh = HDF5Lib.lookup<NativeFunction<H5Drefresh_c>>('H5Drefresh')
            .asFunction();

  int open(int loc_id, Pointer<Uint8> name, int lapl_id) {
    final id = __open(loc_id, name, lapl_id);
    if (id < 0) {
      throw Exception("Failed to open dataset");
    }
    return id;
  }

  int close(int dset_id) {
    final status = __close(dset_id);
    if (status < 0) {
      print(
          '*********  Failing closing dataset with status $status and id $dset_id -- report to Stephan');
      throw Exception("Failed to close dataset");
    }
    return status;
  }

  int getSpace(int dset_id) {
    final space = __getSpace(dset_id);
    if (space < 0) {
      throw Exception("Failed to get dataspace");
    }
    return space;
  }

  int getType(int dset_id) {
    final type = __getType(dset_id);
    if (type < 0) {
      throw Exception("Failed to get datatype");
    }
    return type;
  }

  int getCreatePlist(int dset_id) {
    final plist = __getCreatePlist(dset_id);
    if (plist < 0) {
      throw Exception("Failed to get create property list");
    }
    return plist;
  }

  int getAccessPlist(int dset_id) {
    final plist = __getAccessPlist(dset_id);
    if (plist < 0) {
      throw Exception("Failed to get access property list");
    }
    return plist;
  }

  int read(int dset_id, int mem_type_id, int mem_space_id, int file_space_id,
      int dxpl_id, Pointer buf) {
    final status =
        __read(dset_id, mem_type_id, mem_space_id, file_space_id, dxpl_id, buf);
    if (status < 0) {
      throw Exception("Failed to read dataset");
    }
    return status;
  }

  int refresh(int dset_id) {
    final status = __refresh(dset_id);
    if (status < 0) {
      throw Exception("Failed to refresh dataset");
    }
    return status;
  }
}
