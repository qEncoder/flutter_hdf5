import 'package:hdf5/src/bindings/HDF5_bindings.dart';

class TypeInfo {
  int type;
  int nativeTypeId;
  int size;
  TypeInfo(this.type, this.nativeTypeId, this.size);

  void dispose() {
    HDF5Bindings HDF5lib = HDF5Bindings();
    HDF5lib.H5T.close(nativeTypeId);
  }
}

TypeInfo getTypeInfo(int typeId) {
  HDF5Bindings HDF5lib = HDF5Bindings();

  int type = HDF5lib.H5T.getClass(typeId);
  int nativeTypeId = HDF5lib.H5T.getNativeType(typeId, 0);
  int size = HDF5lib.H5T.getSize(typeId);

  return TypeInfo(type, nativeTypeId, size);
}
