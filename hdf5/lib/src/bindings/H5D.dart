import 'dart:ffi';

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

typedef H5Dread_c = Int64 Function(Int64 dset_id, Int64 mem_type_id,
    Int64 mem_space_id, Int64 file_space_id, Int64 dxpl_id, Pointer buf);
typedef H5Dread = int Function(int dset_id, int mem_type_id, int mem_space_id,
    int file_space_id, int dxpl_id, Pointer buf);

class H5DBindings {
  final H5Dopen open;
  final H5Dclose close;
  final Pointer<NativeFunction<Void Function(Pointer<Void>)>> closePtr;

  final H5Dget_space getSpace;
  final H5Dget_type getType;
  final H5Dread read;

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
        read =
            HDF5Lib.lookup<NativeFunction<H5Dread_c>>('H5Dread').asFunction();
}
