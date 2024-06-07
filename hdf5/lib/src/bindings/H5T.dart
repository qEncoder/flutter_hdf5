import 'dart:ffi';
import 'package:hdf5/src/bindings/H5.dart';

import 'package:hdf5/src/c_to_dart_calls/utility.dart';
import 'package:hdf5/src/utility/logging.dart';

// typedef enum H5T_class_t
const int H5T_NO_CLASS = -1;
const int H5T_INTEGER = 0;
const int H5T_FLOAT = 1;
const int H5T_TIME = 2;
const int H5T_STRING = 3;
const int H5T_BITFIELD = 4;
const int H5T_OPAQUE = 5;
const int H5T_COMPOUND = 6;
const int H5T_REFERENCE = 7;
const int H5T_ENUM = 8;
const int H5T_VLEN = 9;
const int H5T_ARRAY = 10;

const Map<int, String> H5T_class_t = {
  -1: "H5T_NO_CLASS",
  0: "H5T_INTEGER",
  1: "H5T_FLOAT",
  2: "H5T_TIME",
  3: "H5T_STRING",
  4: "H5T_BITFIELD",
  5: "H5T_OPAQUE",
  6: "H5T_COMPOUND",
  7: "H5T_REFERENCE",
  8: "H5T_ENUM",
  9: "H5T_VLEN",
  10: "H5T_ARRAY"
};

final class hvl_t extends Struct {
  @Size()
  external int len; /* Length of VL data (in base type units) */

  external Pointer<Void> p; /* Pointer to VL data */
}

// typedef enum H5T_direction_t
const int H5T_DIR_DEFAULT = 0;
const int H5T_DIR_ASCEND = 1;
const int H5T_DIR_DESCEND = 2;

typedef H5Tclose_c = Int64 Function(Int64 type_id);
typedef H5Tclose = int Function(int type_id);

typedef H5Tget_class_c = Int64 Function(Int64 type_id);
typedef H5Tget_class = int Function(int type_id);

typedef H5Tget_super_c = Int64 Function(Int64 type_id);
typedef H5Tget_super = int Function(int type_id);

typedef H5Tdetect_class_c = Int64 Function(Int64 type_id, Int64 cls);
typedef H5Tdetect_class = int Function(int type_id, int cls);

typedef H5Tget_size_c = Int64 Function(Int64 type_id);
typedef H5Tget_size = int Function(int type_id);

typedef H5Tis_variable_str_c = Int64 Function(Int64 type_id);
typedef H5Tis_variable_str = int Function(int type_id);

typedef H5Tget_native_type_c = Int64 Function(Int64 type_id, Int64 direction);
typedef H5Tget_native_type = int Function(int type_id, int direction);

typedef H5Tget_nmembers_c = Int64 Function(Int64 type_id);
typedef H5Tget_nmembers = int Function(int type_id);

typedef H5Tget_member_type_c = Int64 Function(Int64 type_id, Uint64 membno);
typedef H5Tget_member_type = int Function(int type_id, int membno);

typedef H5Tget_member_class_c = Int64 Function(Int64 type_id, Uint64 membno);
typedef H5Tget_member_class = int Function(int type_id, int membno);

typedef H5Tget_member_offset_c = Int64 Function(Int64 type_id, Uint64 membno);
typedef H5Tget_member_offset = int Function(int type_id, int membno);

typedef H5Tget_member_name_c = Pointer<Uint8> Function(
    Int64 type_id, Int64 membno);
typedef H5Tget_member_name = Pointer<Uint8> Function(int type_id, int membno);

typedef H5Tget_member_value_c = Int64 Function(
    Int64 type_id, Uint64 membno, Pointer value);
typedef H5Tget_member_value = int Function(
    int type_id, int membno, Pointer value);

typedef H5Treclaim_c = Int64 Function(
    Int64 type_id, Int64 space_id, Int64 plist_id, Pointer buf);
typedef H5Treclaim = int Function(
    int type_id, int space_id, int plist_id, Pointer buf);

class H5TBindings {
  final H5Tclose __close;
  final H5Tget_class __getClass;
  final H5Tget_super __getSuper;
  final H5Tdetect_class __detectClass;
  final H5Tget_size __getSize;
  final H5Tis_variable_str __isVariableStr;
  final H5Tget_native_type __getNativeType;
  final H5Tget_nmembers __getNMembers;
  final H5Tget_member_type __getMemberType;
  final H5Tget_member_class __getMemberClass;
  final H5Tget_member_offset __getMemberOffset;
  final H5Tget_member_name __getMemberName;
  final H5Tget_member_value __getMemberValue;
  final H5Treclaim __reclaim;

  final H5free_memory __freeMemory;

  H5TBindings(DynamicLibrary HDF5Lib)
      : __close =
            HDF5Lib.lookup<NativeFunction<H5Tclose_c>>('H5Tclose').asFunction(),
        __getClass =
            HDF5Lib.lookup<NativeFunction<H5Tget_class_c>>('H5Tget_class')
                .asFunction(),
        __getSuper =
            HDF5Lib.lookup<NativeFunction<H5Tget_super_c>>('H5Tget_super')
                .asFunction(),
        __detectClass =
            HDF5Lib.lookup<NativeFunction<H5Tdetect_class_c>>('H5Tdetect_class')
                .asFunction(),
        __getSize = HDF5Lib.lookup<NativeFunction<H5Tget_size_c>>('H5Tget_size')
            .asFunction(),
        __isVariableStr = HDF5Lib.lookup<NativeFunction<H5Tis_variable_str_c>>(
                'H5Tis_variable_str')
            .asFunction(),
        __getNativeType = HDF5Lib.lookup<NativeFunction<H5Tget_native_type_c>>(
                'H5Tget_native_type')
            .asFunction(),
        __getNMembers =
            HDF5Lib.lookup<NativeFunction<H5Tget_nmembers_c>>('H5Tget_nmembers')
                .asFunction(),
        __getMemberType = HDF5Lib.lookup<NativeFunction<H5Tget_member_type_c>>(
                'H5Tget_member_type')
            .asFunction(),
        __getMemberClass =
            HDF5Lib.lookup<NativeFunction<H5Tget_member_class_c>>(
                    'H5Tget_member_class')
                .asFunction(),
        __getMemberOffset =
            HDF5Lib.lookup<NativeFunction<H5Tget_member_offset_c>>(
                    'H5Tget_member_offset')
                .asFunction(),
        __getMemberName = HDF5Lib.lookup<NativeFunction<H5Tget_member_name_c>>(
                'H5Tget_member_name')
            .asFunction(),
        __getMemberValue =
            HDF5Lib.lookup<NativeFunction<H5Tget_member_value_c>>(
                    'H5Tget_member_value')
                .asFunction(),
        __reclaim = HDF5Lib.lookup<NativeFunction<H5Treclaim_c>>('H5Treclaim')
            .asFunction(),
        __freeMemory =
            HDF5Lib.lookup<NativeFunction<H5free_memory_c>>('H5free_memory')
                .asFunction();

  void close(int type_id) {
    final status = __close(type_id);
    if (status < 0) {
      logger.severe('Failed to close datatype');
      throw Exception('Failed to close datatype');
    }
  }

  int getClass(int type_id) {
    final cls = __getClass(type_id);
    if (cls < 0) {
      logger.severe('Failed to get datatype class');
      throw Exception('Failed to get datatype class');
    }
    return cls;
  }

  int getSuper(int type_id) {
    final super_id = __getSuper(type_id);
    if (super_id < 0) {
      logger.severe('Failed to get super datatype');
      throw Exception('Failed to get super datatype');
    }
    return super_id;
  }

  int detectClass(int type_id, int cls) {
    final status = __detectClass(type_id, cls);
    if (status < 0) {
      logger.severe('Failed to detect datatype class');
      throw Exception('Failed to detect datatype class');
    }
    return status;
  }

  int getSize(int type_id) {
    final size = __getSize(type_id);
    if (size < 0) {
      logger.severe('Failed to get datatype size');
      throw Exception('Failed to get datatype size');
    }
    return size;
  }

  int isVariableStr(int type_id) {
    final isVarStr = __isVariableStr(type_id);
    if (isVarStr < 0) {
      logger.severe('Failed to check if datatype is variable-length string');
      throw Exception('Failed to check if datatype is variable-length string');
    }
    return isVarStr;
  }

  int getNativeType(int type_id, int direction) {
    final native_type = __getNativeType(type_id, direction);
    if (native_type < 0) {
      logger.severe('Failed to get native datatype');
      throw Exception('Failed to get native datatype');
    }
    return native_type;
  }

  int getNMembers(int type_id) {
    final nMembers = __getNMembers(type_id);
    if (nMembers < 0) {
      logger.severe('Failed to get number of members in compound datatype');
      throw Exception('Failed to get number of members in compound datatype');
    }
    return nMembers;
  }

  int getMemberType(int type_id, int membno) {
    final member_type = __getMemberType(type_id, membno);
    if (member_type < 0) {
      logger.severe('Failed to get member datatype');
      throw Exception('Failed to get member datatype');
    }
    return member_type;
  }

  int getMemberClass(int type_id, int membno) {
    final member_class = __getMemberClass(type_id, membno);
    if (member_class < 0) {
      logger.severe('Failed to get member class');
      throw Exception('Failed to get member class');
    }
    return member_class;
  }

  int getMemberOffset(int type_id, int membno) {
    final offset = __getMemberOffset(type_id, membno);
    if (offset < 0) {
      logger.severe('Failed to get member offset');
      throw Exception('Failed to get member offset');
    }
    return offset;
  }

  String getMemberName(int type_id, int membno) {
    Pointer<Uint8> memberNamePtr = __getMemberName(type_id, membno);
    if (memberNamePtr == nullptr) {
      logger.severe('Failed to get member name');
      throw Exception('Failed to get member name');
    }

    String memberName = charToString(memberNamePtr);
    __freeMemory(memberNamePtr);
    return memberName;
  }

  void getMemberValue(int type_id, int membno, Pointer buffer) {
    final status = __getMemberValue(type_id, membno, buffer);
    if (status < 0) {
      logger.severe('Failed to get member value');
      throw Exception('Failed to get member value');
    }
  }

  void reclaim(int type_id, int space_id, int plist_id, Pointer buf) {
    final status = __reclaim(type_id, space_id, plist_id, buf);
    if (status < 0) {
      logger.severe('Failed to reclaim datatype');
      throw Exception('Failed to reclaim datatype');
    }
  }
}
