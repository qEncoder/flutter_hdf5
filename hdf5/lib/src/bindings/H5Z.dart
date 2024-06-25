import 'package:hdf5/src/utility/enum_utils.dart';

enum H5Z_filter_t implements IndexEnum<H5Z_filter_t> {
  ERROR(-1, "Error"),
  NONE(0, "None"),
  DEFLATE(1, "GZIP"),
  SHUFFLE(2, "Shuffle"),
  FLETCHER32(3, "Fletcher32"),
  SZIP(4, "SZip"),
  NBIT(5, "NBit"),
  SCALEOFFSET(6, "ScaleOffset");

  final int value;
  final String string;
  const H5Z_filter_t(this.value, this.string);

  @override
  toString() => string;

  static H5Z_filter_t fromIdx(int value) => IndexEnum.fromIdx(H5Z_filter_t.values, value);
}