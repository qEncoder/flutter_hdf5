import 'dart:ffi';

import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/c_to_dart_calls/utility.dart';
import 'package:hdf5/src/utility/enum_utils.dart';
import 'package:hdf5/src/utility/logging.dart';



enum H5O_type_t implements IndexEnum<H5O_type_t> {
  UNKNOWN(-1, "Unknown"),
  GROUP(0, "Group"),
  DATASET(1, "Dataset"),
  NAMED_DATATYPE(2, "Named Datatype"),
  MAP(3, "Map"),
  NTYPES(4, "NTypes");

  final int value;
  final String string;
  const H5O_type_t(this.value, this.string);

  @override
  toString() => string;

  static H5O_type_t fromIdx(int value) => IndexEnum.fromIdx(H5O_type_t.values, value);
}

const int H5O_INFO_BASIC =
    1; //**< Fill in the fileno, addr, type, and rc fields */
const int H5O_INFO_TIME =
    2; //**< Fill in the atime, mtime, ctime, and btime fields */
const int H5O_INFO_NUM_ATTRS = 4; //**< Fill in the num_attrs field */
const int H5O_INFO_HDR = 8; //**< Fill in the hdr field */
const int H5O_INFO_META_SIZE = 16; //**< Fill in the meta_size field */
const int H5O_INFO_ALL = 31;

final class H5O_info_t extends Struct {
  @Uint64()
  external int fileno;

  @Array<Uint8>(16)
  external Array<Uint8> token;

  @Int32()
  external int type;

  @Uint64()
  external int rc;

  @Int64()
  external int atime;

  @Int64()
  external int mtime;

  @Int64()
  external int ctime;

  @Int64()
  external int btime;

  @Int64()
  external int num_attrs;
}

typedef H5Oget_info_by_idx_c = Int64 Function(
    Int64 loc_id,
    Pointer<Uint8> group_name,
    Int64 idx_type,
    Int64 order,
    Int64 n,
    Pointer<H5O_info_t> oinfo,
    Uint64 fields,
    Int64 lapl_id);
typedef H5Oget_info_by_idx = int Function(
    int loc_id,
    Pointer<Uint8> group_name,
    int idx_type,
    int order,
    int n,
    Pointer<H5O_info_t> oinfo,
    int fields,
    int lapl_id);

class H5OBindings {
  final H5Oget_info_by_idx __getInfoByIdx;
  final Pointer<Uint8> grp_name = strToChar('.');

  H5OBindings(DynamicLibrary HDF5Lib)
      : __getInfoByIdx = HDF5Lib.lookup<NativeFunction<H5Oget_info_by_idx_c>>(
                'H5Oget_info_by_idx3')
            .asFunction();

  void getInfoByIdx(int loc_id, int index, Pointer<H5O_info_t> oinfo) {
    final status = __getInfoByIdx(loc_id, grp_name, H5_INDEX_NAME, H5_ITER_INC,
        index, oinfo, H5O_INFO_BASIC, H5P_DEFAULT);
    if (status < 0) {
      logger.severe('Failed to get link info by index for location $loc_id');
      throw Exception('Failed to get link info by index');
    }
  }
}
