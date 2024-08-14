import 'dart:ffi';

import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/utility/logging.dart';

class TypeInfo implements Finalizable {
  H5T_class_t type;
  int nativeTypeId;
  int size;
  int typeId;

  TypeInfo(this.type, this.nativeTypeId, this.size, {this.typeId = -1});

  @override
  String toString() {
    if (type == H5T_class_t.INTEGER || type == H5T_class_t.FLOAT || type == H5T_class_t.BITFIELD) {
      try{
        return HDF5Bindings().H5T.getBaseTypeFromNativeType(nativeTypeId, size).toString();
      } catch (e, stacktrace) {
        logger.warning("Failed to get base type from native type: $e\n$stacktrace");
        return type.toString();
      }
    } else {
      return type.toString();
    }
  }

  void dispose() {
    HDF5Bindings HDF5lib = HDF5Bindings();
    HDF5lib.H5T.close(nativeTypeId);
    HDF5lib.H5T.close(typeId);
  }
}

TypeInfo getTypeInfo(int typeId) {
  HDF5Bindings HDF5lib = HDF5Bindings();

  H5T_class_t type = HDF5lib.H5T.getClass(typeId);
  int nativeTypeId = HDF5lib.H5T.getNativeType(typeId, 0);
  int size = HDF5lib.H5T.getSize(nativeTypeId);

  return TypeInfo(type, nativeTypeId, size, typeId: typeId);
}
