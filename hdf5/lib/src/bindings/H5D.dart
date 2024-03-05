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
  final H5Dopen open;
  final H5Dclose close;
  final Pointer<NativeFunction<Void Function(Pointer<Void>)>> closePtr;

  final H5Dget_space getSpace;
  final H5Dget_type getType;
  final H5Dget_create_plist getCreatePlist;
  final H5Dget_access_plist getAccessPlist;
  final H5Dread read;
  final H5Drefresh refresh;

  H5DBindings(DynamicLibrary HDF5Lib)
      : open =
            HDF5Lib.lookup<NativeFunction<H5Dopen_c>>('H5Dopen2').asFunction(),
        close =
            HDF5Lib.lookup<NativeFunction<H5Dclose_c>>('H5Dclose').asFunction(),
        closePtr = HDF5Lib.lookup<NativeFunction<H5DcloseNative>>('H5Dclose'),
        getSpace =
            HDF5Lib.lookup<NativeFunction<H5Dget_space_c>>('H5Dget_space')
                .asFunction(),
        getType = HDF5Lib.lookup<NativeFunction<H5Dget_type_c>>('H5Dget_type')
            .asFunction(),
        getCreatePlist = HDF5Lib.lookup<NativeFunction<H5Dget_create_plist_c>>(
                'H5Dget_create_plist')
            .asFunction(),
        getAccessPlist = HDF5Lib.lookup<NativeFunction<H5Dget_access_plist_c>>(
                'H5Dget_access_plist').asFunction(),
        read =
            HDF5Lib.lookup<NativeFunction<H5Dread_c>>('H5Dread').asFunction(),
        refresh = HDF5Lib.lookup<NativeFunction<H5Drefresh_c>>('H5Drefresh').asFunction();
        
}
