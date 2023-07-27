import 'dart:ffi';

typedef H5Gopen_c = Int64 Function(
    Int64 group_id, Pointer<Uint8> name, Int64 gapl_id);
typedef H5Gopen = int Function(int group_id, Pointer<Uint8> name, int gapl_id);

typedef H5Gclose_c = Int64 Function(Int64 group_id);
typedef H5Gclose = int Function(int group_id);
// little hack to interpret int type as pointer. This is fine one 64 by systems.
typedef H5GcloseNative = Void Function(Pointer<void> attr_id);

typedef H5Gget_num_objs_c = Int64 Function(
    Int64 group_id, Pointer<Int64> num_objs);
typedef H5Gget_num_objs = int Function(int group_id, Pointer<Int64> num_objs);

class H5GBindings {
  final H5Gopen open;
  final H5Gclose close;
  final H5Gget_num_objs getNumObjs;
  final Pointer<NativeFunction<Void Function(Pointer<Void>)>> closePtr;

  H5GBindings(DynamicLibrary HDF5Lib)
      : open =
            HDF5Lib.lookup<NativeFunction<H5Gopen_c>>('H5Gopen2').asFunction(),
        close =
            HDF5Lib.lookup<NativeFunction<H5Gclose_c>>('H5Gclose').asFunction(),
        closePtr = HDF5Lib.lookup<NativeFunction<H5GcloseNative>>('H5Gclose'),
        getNumObjs =
            HDF5Lib.lookup<NativeFunction<H5Gget_num_objs_c>>('H5Gget_num_objs')
                .asFunction();
}
