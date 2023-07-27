import 'dart:ffi';

// typedef enum H5T_class_t
const int H5T_NO_CLASS  = -1; 
const int H5T_INTEGER   = 0; 
const int H5T_FLOAT     = 1; 
const int H5T_TIME      = 2; 
const int H5T_STRING    = 3; 
const int H5T_BITFIELD  = 4; 
const int H5T_OPAQUE    = 5; 
const int H5T_COMPOUND  = 6; 
const int H5T_REFERENCE = 7; 
const int H5T_ENUM      = 8; 
const int H5T_VLEN      = 9; 
const int H5T_ARRAY     = 10;

const Map<int, String> H5T_class_t= {-1 : "H5T_NO_CLASS", 0 : "H5T_INTEGER", 1 : "H5T_FLOAT", 2 : "H5T_TIME",
                                       3 : "H5T_STRING", 4 : "H5T_BITFIELD", 5 : "H5T_OPAQUE", 6 : "H5T_COMPOUND", 
                                       7 : "H5T_REFERENCE", 8 : "H5T_ENUM", 9 : "H5T_VLEN", 10 : "H5T_ARRAY"};

// typedef enum H5T_direction_t
const int H5T_DIR_DEFAULT = 0;
const int H5T_DIR_ASCEND  = 1;
const int H5T_DIR_DESCEND = 2; 

typedef H5Tclose_c = Int64 Function(Int64 type_id);
typedef H5Tclose = int Function(int type_id);

typedef H5Tget_class_c = Int64 Function(Int64 type_id);
typedef H5Tget_class = int Function(int type_id);

typedef H5Tget_size_c = Int64 Function(Int64 type_id);
typedef H5Tget_size = int Function(int type_id);

typedef H5Tis_variable_str_c = Int64 Function(Int64 type_id);	
typedef H5Tis_variable_str = int Function(int type_id);	

typedef H5Tget_native_type_c =  Int64 Function(Int64 type_id, Int64 direction);
typedef H5Tget_native_type =  int Function(int type_id, int direction);

typedef H5Tget_nmembers_c = Int64 Function(Int64 type_id);
typedef H5Tget_nmembers = int Function(int type_id);

typedef H5Tget_member_type_c = Int64 Function(Int64 type_id, Uint64 membno);
typedef H5Tget_member_type = int Function(int type_id, int membno);

typedef H5Tget_member_class_c = Int64 Function(Int64 type_id, Uint64 membno);
typedef H5Tget_member_class = int Function(int type_id, int membno);

typedef H5Tget_member_offset_c = Int64 Function(Int64 type_id, Uint64 membno);
typedef H5Tget_member_offset = int Function(int type_id, int membno);

typedef H5Tget_member_name_c = Pointer<Uint8> Function(Int64 type_id, Int64 membno);
typedef H5Tget_member_name = Pointer<Uint8> Function(int type_id, int membno);



class H5TBindings{
  final H5Tclose close;
  final H5Tget_class getClass;
  final H5Tget_size getSize;
  final H5Tis_variable_str isVariableStr;
  final H5Tget_native_type getNativeType;
  final H5Tget_nmembers getNMembers;
  final H5Tget_member_type getMemberType;
  final H5Tget_member_class getMemberClass;
  final H5Tget_member_offset getMemberOffset;
  final H5Tget_member_name getMemberName;

  H5TBindings(DynamicLibrary HDF5Lib):
    close = HDF5Lib.lookup<NativeFunction<H5Tclose_c>>('H5Tclose').asFunction(),
    getClass = HDF5Lib.lookup<NativeFunction<H5Tget_class_c>>('H5Tget_class').asFunction(),
    getSize = HDF5Lib.lookup<NativeFunction<H5Tget_size_c>>('H5Tget_size').asFunction(),
    isVariableStr = HDF5Lib.lookup<NativeFunction<H5Tis_variable_str_c>>('H5Tis_variable_str').asFunction(),
    getNativeType = HDF5Lib.lookup<NativeFunction<H5Tget_native_type_c>>('H5Tget_native_type').asFunction(),
    getNMembers = HDF5Lib.lookup<NativeFunction<H5Tget_nmembers_c>>('H5Tget_nmembers').asFunction(),
    getMemberType = HDF5Lib.lookup<NativeFunction<H5Tget_member_type_c>>('H5Tget_member_type').asFunction(),
    getMemberClass = HDF5Lib.lookup<NativeFunction<H5Tget_member_class_c>>('H5Tget_member_class').asFunction(),
    getMemberOffset = HDF5Lib.lookup<NativeFunction<H5Tget_member_offset_c>>('H5Tget_member_offset').asFunction(),
    getMemberName = HDF5Lib.lookup<NativeFunction<H5Tget_member_name_c>>('H5Tget_member_name').asFunction();
}