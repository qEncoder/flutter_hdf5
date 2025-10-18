import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:hdf5/src/c_to_dart_calls/utility.dart';
import 'package:hdf5/src/utility/logging.dart';

const int H5F_ACC_RDONLY = 0; // Allows read-only access to file
const int H5F_ACC_RDWR = 1; //  Allows read and write access to file
const int H5F_ACC_TRUNC = 2; // Truncate file, if it already exists
const int H5F_ACC_EXCL = 4; // Fail if file already exists
const int H5F_ACC_SWMR_WRITE =
    32; // Indicates that the file is open for writing in a single-writer/multi-writer (SWMR) scenario.
const int H5F_ACC_SWMR_READ =
    64; // Indicates that the file is open for reading in a single-writer/multi-reader (SWMR) scenario.

typedef H5Fopen_c = Int64 Function(
    Pointer<Uint8> filename, Uint16 flags, Int64 fapl_id);
typedef H5Fopen = int Function(Pointer<Uint8> filename, int flags, int fapl_id);

typedef H5Fcreate_c = Int64 Function(
    Pointer<Uint8> filename, Uint16 flags, Int64 fcpl_id, Int64 fapl_id);
typedef H5Fcreate = int Function(Pointer<Uint8> filename, int flags, int fcpl_id, int fapl_id);

typedef H5Fclose_c = Int64 Function(Int64 file_id);
typedef H5Fclose = int Function(int file_id);

// little hack to interpret int type as pointer. This is fine one 64 by systems.
typedef H5FcloseNative = Void Function(Pointer<void> attr_id);

class H5FBindings {
  final H5Fopen __open;
  final H5Fcreate __create;
  final H5Fclose __close;

  H5FBindings(DynamicLibrary HDF5Lib)
      : __open =
            HDF5Lib.lookup<NativeFunction<H5Fopen_c>>('H5Fopen').asFunction(),
        __create =
            HDF5Lib.lookup<NativeFunction<H5Fcreate_c>>('H5Fcreate').asFunction(),
        __close =
            HDF5Lib.lookup<NativeFunction<H5Fclose_c>>('H5Fclose').asFunction();
  int open(String fileName, int flags, int fapl_id) {
    Pointer<Uint8> namePtr = strToChar(fileName);
    final id = __open(namePtr, flags, fapl_id);
    calloc.free(namePtr);
    logger.info('Opened file $fileName with id $id');

    if (id < 0) {
      logger.severe('Failed to open file $fileName');
      throw Exception('Failed to open file');
    }
    return id;
  }

  int create(String fileName, int flags, int fcpl_id, int fapl_id) {
    Pointer<Uint8> namePtr = strToChar(fileName);
    final id = __create(namePtr, flags, fcpl_id, fapl_id);
    calloc.free(namePtr);
    logger.info('Created file $fileName with id $id');

    if (id < 0) {
      logger.severe('Failed to create file $fileName');
      throw Exception('Failed to create file');
    }
    return id;
  }

  void close(int file_id) {
    final status = __close(file_id);
    logger.info('Closed file with id $file_id');
    if (status < 0) {
      logger.severe('Failed to close file with id $file_id');
      print(
          '**************Failed to close file with id $file_id -- report to Stephan');
      throw Exception('Failed to close file');
    }
  }
}
