import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/c_to_dart_calls/type_info.dart';
import 'package:hdf5/src/c_to_dart_calls/space_info.dart';

import 'package:numd/numd.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

ndarray readData(datasetId) {
  HDF5Bindings HDF5lib = HDF5Bindings();

  int typeId = HDF5lib.H5D.getType(datasetId);
  int spaceId = HDF5lib.H5D.getSpace(datasetId);

  TypeInfo typeInfo = getTypeInfo(typeId);
  SpaceInfo spaceInfo = getSpaceInfo(spaceId);

  ndarray dataOut = ndarray.fromShape([1]);
  if (spaceInfo.rank != 0) {
    dataOut = ndarray.fromShape(spaceInfo.dim);
  }

  int size = typeInfo.size * dataOut.size;

  Pointer<Int8> data = calloc<Int8>(size);
  HDF5lib.H5D.read(
      datasetId, typeInfo.nativeTypeId, H5S_ALL, H5S_ALL, H5P_DEFAULT, data);

  // note that due some limitations in numd, a conversion must be performed to double

  switch (typeInfo.size) {
    case 4:
      switch (typeInfo.type) {
        case H5T_FLOAT:
          Pointer<Float> dataPointer = data.cast<Float>();
          for (var i = 0; i < dataOut.size; i++) {
            dataOut.flat[i] = dataPointer[i];
          }
          break;
        case H5T_INTEGER:
          Pointer<Int32> dataPointer = data.cast<Int32>();
          for (var i = 0; i < dataOut.size; i++) {
            int value = dataPointer[i];
            dataOut.flat[i] = value.toDouble();
          }
          break;
        default:
          throw "type ${H5T_class_t[typeInfo.type]} currently not supported";
      }
      break;
    case 8:
      switch (typeInfo.type) {
        case H5T_FLOAT:
          Pointer<Double> dataPointer = data.cast<Double>();
          for (int i = 0; i < dataOut.size; i++) {
            dataOut.flat[i] = dataPointer[i];
          }
          break;
        case H5T_INTEGER:
          Pointer<Int64> dataPointer = data.cast<Int64>();
          for (var i = 0; i < dataOut.size; i++) {
            int value = dataPointer[i];
            dataOut.flat[i] = value.toDouble();
          }
          break;
        default:
          throw "type ${H5T_class_t[typeInfo.type]} currently not supported";
      }
      break;
    default:
      throw "Only 32 and 64 bit types are supported.";
  }
  typeInfo.dispose();
  spaceInfo.dispose();
  calloc.free(data);
  return dataOut;
}
