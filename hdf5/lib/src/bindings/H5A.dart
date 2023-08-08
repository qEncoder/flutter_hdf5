import 'dart:ffi';

typedef H5Aopen_c = Int64 Function(
    Int64 obj_id, Pointer<Uint8> attr_name, Int64 aapl_id);
typedef H5Aopen = int Function(
    int obj_id, Pointer<Uint8> attr_name, int aapl_id);

typedef H5Aclose_c = Int64 Function(Int64 attr_id);
typedef H5Aclose = int Function(int attr_id);

// little hack to interpret int type as pointer. This is fine one 64 by systems.
typedef H5AcloseNative = Void Function(Pointer<void> attr_id);

typedef H5Aget_num_attrs_c = Int64 Function(Int64 loc_id);
typedef H5Aget_num_attrs = int Function(int loc_id);

typedef H5Aget_type_c = Int64 Function(Int64 attr_id);
typedef H5Aget_type = int Function(int attr_id);

typedef H5Aget_space_c = Int64 Function(Int64 attr_id);
typedef H5Aget_space = int Function(int attr_id);

typedef H5Aget_name_by_idx_c = Int64 Function(
    Int64 loc_id,
    Pointer<Uint8> obj_name,
    Int32 idx_type,
    Int32 order,
    Uint64 n,
    Pointer<Uint8> name,
    Uint64 size,
    Int64 lapl_id);
typedef H5Aget_name_by_idx = int Function(int loc_id, Pointer<Uint8> obj_name,
    int idx_type, int order, int n, Pointer<Uint8> name, int size, int lapl_id);

typedef H5Aread_c = Int64 Function(Int64 attr_id, Int64 type_id, Pointer buf);
typedef H5Aread = int Function(int attr_id, int type_id, Pointer buf);

class H5ABindings {
  final H5Aopen open;
  final H5Aclose close;
  final Pointer<NativeFunction<Void Function(Pointer<Void>)>> closePtr;
  final H5Aget_num_attrs getNumAttrs;
  final H5Aget_name_by_idx getNameByIdx;

  final H5Aget_type getType;
  final H5Aget_space getSpace;

  final H5Aread read;

  H5ABindings(DynamicLibrary HDF5Lib)
      : open =
            HDF5Lib.lookup<NativeFunction<H5Aopen_c>>('H5Aopen').asFunction(),
        close =
            HDF5Lib.lookup<NativeFunction<H5Aclose_c>>('H5Aclose').asFunction(),
        closePtr = HDF5Lib.lookup<NativeFunction<H5AcloseNative>>('H5Aclose'),
        getNumAttrs = HDF5Lib.lookup<NativeFunction<H5Aget_num_attrs_c>>(
                'H5Aget_num_attrs')
            .asFunction(),
        getNameByIdx = HDF5Lib.lookup<NativeFunction<H5Aget_name_by_idx_c>>(
                "H5Aget_name_by_idx")
            .asFunction(),
        getType = HDF5Lib.lookup<NativeFunction<H5Aget_type_c>>('H5Aget_type')
            .asFunction(),
        getSpace =
            HDF5Lib.lookup<NativeFunction<H5Aget_space_c>>('H5Aget_space')
                .asFunction(),
        read =
            HDF5Lib.lookup<NativeFunction<H5Aread_c>>("H5Aread").asFunction();
}
