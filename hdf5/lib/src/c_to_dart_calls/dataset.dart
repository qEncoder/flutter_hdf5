import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/c_to_dart_calls/type_info.dart';
import 'package:hdf5/src/c_to_dart_calls/space_info.dart';

import 'package:numd/numd.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

ndarray readData(datasetId, dynamic idx) {
  HDF5Bindings HDF5lib = HDF5Bindings();

  int typeId = HDF5lib.H5D.getType(datasetId);
  int spaceId = HDF5lib.H5D.getSpace(datasetId);

  TypeInfo typeInfo = getTypeInfo(typeId);
  SpaceInfo spaceInfo = getSpaceInfo(spaceId);

  ({int memSpaceId, int fileSpaceId, List<int> outputDim}) space =
      hypersliceData(spaceInfo.dim, idx);

  ndarray dataOut = ndarray.fromShape([1]);
  if (space.outputDim.isNotEmpty) dataOut = ndarray.fromShape(space.outputDim);

  int size = typeInfo.size * dataOut.size;

  Pointer<Int8> data = calloc<Int8>(size);
  HDF5lib.H5D.read(datasetId, typeInfo.nativeTypeId, space.memSpaceId,
      space.fileSpaceId, H5P_DEFAULT, data);

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
  HDF5lib.H5S.close(space.memSpaceId);
  HDF5lib.H5S.close(space.fileSpaceId);
  calloc.free(data);
  return dataOut;
}

({int memSpaceId, int fileSpaceId, List<int> outputDim}) hypersliceData(
    List<int> dim, dynamic idx) {
  HDF5Bindings HDF5lib = HDF5Bindings();

  List<int> offset = [];
  List<int> count = [];
  List<int> outputDim = [];

  if (idx is! List) {
    idx = [idx];
  }

  for (int i = 0; i < dim.length; i++) {
    if (i < idx.length) {
      if (idx[i] is int) {
        offset.add(idx[i]);
        count.add(1);
      } else if (idx[i] is Slice) {
        Slice sliceCpy = idx[i].getFormattedSlice(dim[i]);
        if (sliceCpy.start <= sliceCpy.stop! && sliceCpy.stop! <= dim[i]) {
          offset.add(sliceCpy.start);
          count.add(sliceCpy.size);
          outputDim.add(sliceCpy.size);
        } else {
          throw Exception(
              'The provided slice is invalid. Please ensure that the slice parameters are within the valid range.');
        }
      } else {
        throw Exception(
            'The provided type is invalid. Please ensure that the type is either int or Slice.');
      }
    } else {
      offset.add(0);
      count.add(dim[i]);
      outputDim.add(dim[i]);
    }
  }
  Pointer<Int64> dimMS = intListToCArray(outputDim);
  int memSpaceId =
      HDF5lib.H5S.createSimple(outputDim.length, dimMS, Pointer.fromAddress(0));
  calloc.free(dimMS);

  Pointer<Int64> dimDS = intListToCArray(dim);
  int fileSpaceId =
      HDF5lib.H5S.createSimple(dim.length, dimDS, Pointer.fromAddress(0));
  calloc.free(dimDS);

  Pointer<Int64> offsetDS = intListToCArray(offset);
  Pointer<Int64> countDS = intListToCArray(count);

  HDF5lib.H5S.selectHyperslab(fileSpaceId, H5S_SELECT_SET, offsetDS,
      Pointer.fromAddress(0), countDS, Pointer.fromAddress(0));
  calloc.free(offsetDS);
  calloc.free(countDS);

  return (
    memSpaceId: memSpaceId,
    fileSpaceId: fileSpaceId,
    outputDim: outputDim
  );
}
