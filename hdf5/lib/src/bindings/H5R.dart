import 'dart:ffi';

const int H5R_BADTYPE = -1;
const int H5R_OBJECT = 0;
const int H5R_DATASET_REGION = 1;
const int H5R_MAXTYPE = 2;

const Map<int, String> H5R_type_t = {
  -1: "H5R_BADTYPE",
  0: "H5R_OBJECT",
  1: "H5R_DATASET_REGION",
  2: "H5R_MAXTYPE"
};

typedef H5Rdereference_c = Int64 Function(
    Int64 dataset, Int64 oapl_id, Int32 ref_type, Pointer ref);
typedef H5Rdereference = int Function(
    int dataset, int oapl_id, int ref_type, Pointer ref);

typedef H5Rget_name_c = Int64 Function(
    Int64 loc_id, Int32 ref_type, Pointer ref, Pointer<Uint8> name, Int64 size);
typedef H5Rget_name = int Function(
    int loc_id, int ref_type, Pointer ref, Pointer<Uint8> name, int size);
typedef H5Rget_obj_type_c = Int64 Function(
    Int64 id, Int32 ref_type, Pointer ref, Pointer<Int32> obj_type);
typedef H5Rget_obj_type = int Function(
    int id, int ref_type, Pointer ref, Pointer<Int32> obj_type);

class H5RBindings {
  final H5Rdereference deReference;
  final H5Rget_name getName;
  final H5Rget_obj_type getObjType;

  H5RBindings(DynamicLibrary HDF5Lib)
      : deReference =
            HDF5Lib.lookup<NativeFunction<H5Rdereference_c>>('H5Rdereference2')
                .asFunction(),
        getName = HDF5Lib.lookup<NativeFunction<H5Rget_name_c>>('H5Rget_name')
            .asFunction(),
        getObjType = HDF5Lib.lookup<NativeFunction<H5Rget_obj_type_c>>(
                'H5Rget_obj_type2')
            .asFunction();
}
