import 'dart:ffi';

const int H5F_ACC_RDONLY = 0; // Allows read-only access to file
const int H5F_ACC_RDWR = 1; //  Allows read and write access to file
const int H5F_ACC_SWMR_WRITE =
    32; // Indicates that the file is open for writing in a single-writer/multi-writer (SWMR) scenario.
const int H5F_ACC_SWMR_READ =
    64; // Indicates that the file is open for reading in a single-writer/multi-reader (SWMR) scenario.

typedef H5Fopen_c = Int64 Function(
    Pointer<Uint8> filename, Uint16 flags, Int64 fapl_id);
typedef H5Fopen = int Function(Pointer<Uint8> filename, int flags, int fapl_id);

typedef H5Fclose_c = Int64 Function(Int64 file_id);
typedef H5Fclose = int Function(int file_id);

// little hack to interpret int type as pointer. This is fine one 64 by systems.
typedef H5FcloseNative = Void Function(Pointer<void> attr_id);

class H5FBindings {
  final H5Fopen open;
  final H5Fclose close;
  final Pointer<NativeFunction<Void Function(Pointer<Void>)>> closePtr;

  H5FBindings(DynamicLibrary HDF5Lib)
      : open =
            HDF5Lib.lookup<NativeFunction<H5Fopen_c>>('H5Fopen').asFunction(),
        close =
            HDF5Lib.lookup<NativeFunction<H5Fclose_c>>('H5Fclose').asFunction(),
        closePtr = HDF5Lib.lookup<NativeFunction<H5FcloseNative>>('H5Fclose');
}
