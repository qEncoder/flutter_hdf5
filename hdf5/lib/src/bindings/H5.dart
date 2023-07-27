import 'dart:ffi';

typedef H5free_memory_c = Int64 Function(Pointer mem);
typedef H5free_memory = int Function(Pointer mem);

const int H5P_DEFAULT = 0;

// enum H5_index_t translated to list of consts
const int H5_INDEX_UNKNOWN = -1;
const int H5_INDEX_NAME = 0;
const int H5_INDEX_CRT_ORDER = 1;
const int H5_INDEX_N = 2;

// enum H5_iter_order_t translated to list of consts
const int H5_ITER_UNKNOWN = -1;
const int H5_ITER_INC = 0;
const int H5_ITER_DEC = 1;
const int H5_ITER_NATIVE = 2;
const int H5_ITER_N = 3;

class H5Bindings{
  final H5free_memory freeMemory;

  H5Bindings(DynamicLibrary HDF5Lib):
    freeMemory = HDF5Lib.lookup<NativeFunction<H5free_memory_c>>('H5free_memory').asFunction();
}