import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:hdf5/src/utility/logging.dart';

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
  final H5Gopen __open;
  final H5Gclose __close;
  final H5Gget_num_objs __getNumObjs;

  H5GBindings(DynamicLibrary HDF5Lib)
      : __open =
            HDF5Lib.lookup<NativeFunction<H5Gopen_c>>('H5Gopen2').asFunction(),
        __close =
            HDF5Lib.lookup<NativeFunction<H5Gclose_c>>('H5Gclose').asFunction(),
        __getNumObjs =
            HDF5Lib.lookup<NativeFunction<H5Gget_num_objs_c>>('H5Gget_num_objs')
                .asFunction();

  int open(int group_id, Pointer<Uint8> name, int gapl_id) {
    final id = __open(group_id, name, gapl_id);
    logger.info('Opened group with id $id');
    if (id < 0) {
      logger.severe('Failed to open group with id $group_id');
      throw Exception('Failed to open group');
    }
    return id;
  }

  void close(int group_id) {
    final status = __close(group_id);
    logger.info('Closed group with id $group_id');
    if (status < 0) {
      logger.severe('Failed to close group with id $group_id');
      throw Exception('Failed to close group');
    }
  }

  int getNumObjs(int group_id) {
    final Pointer<Int64> num_objs = calloc<Int64>(1);
    final status = __getNumObjs(group_id, num_objs);
    if (status < 0) {
      logger.severe('Failed to get number of objects in group with id $group_id');
      throw Exception('Failed to get number of objects in group');
    }
    final result = num_objs.value;
    calloc.free(num_objs);
    return result;
  }
}
