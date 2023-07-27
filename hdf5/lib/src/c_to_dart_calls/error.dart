import 'package:hdf5/src/bindings/HDF5_bindings.dart';

class H5TTypeException implements Exception {
  int typeInfoCls;
  H5TTypeException(this.typeInfoCls);

  String errMsg() => 'Type ${H5T_class_t[typeInfoCls]} not supported';
}

class H5RankException implements Exception {
  int rank;
  H5RankException(this.rank);

  String errMsg() =>
      'Rank if the data is $rank, currenly only rank 0 an 1 supported';
}
