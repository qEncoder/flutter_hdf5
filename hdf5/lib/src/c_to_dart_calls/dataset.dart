import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/c_to_dart_calls/attributes.dart';
import 'package:hdf5/src/c_to_dart_calls/type_info.dart';
import 'package:hdf5/src/c_to_dart_calls/space_info.dart';
import 'package:hdf5/src/utility/logging.dart';

import 'package:numd/numd.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

ndarray readData(datasetId, dynamic idx, {bool readImaginary = false}) {
  logger.info("Reading data from dataset $datasetId");
  HDF5Bindings HDF5lib = HDF5Bindings();

  int typeId = HDF5lib.H5D.getType(datasetId);
  int spaceId = HDF5lib.H5D.getSpace(datasetId);

  TypeInfo typeInfo = getTypeInfo(typeId);
  SpaceInfo spaceInfo = getSpaceInfo(spaceId);

  ({int memSpaceId, int fileSpaceId, List<int> outputDim}) space =
      hypersliceData(spaceInfo, idx);

  ndarray dataOut = ndarray.fromShape([1]);
  if (space.outputDim.isNotEmpty) dataOut = ndarray.fromShape(space.outputDim);

  int size = typeInfo.size * dataOut.size;

  Pointer<Int8> data = calloc<Int8>(size);
  HDF5lib.H5D.read(datasetId, typeInfo.nativeTypeId, space.memSpaceId,
      space.fileSpaceId, H5P_DEFAULT, data);

  // note that due some limitations in numd, a conversion must be performed to double
  switch (typeInfo.type){
    case H5T_class_t.FLOAT:
      switch (typeInfo.size){
        case 4:
          Pointer<Float> dataPointer = data.cast<Float>();
          for (var i = 0; i < dataOut.size; i++) {
            dataOut.flat[i] = dataPointer[i];
          }
          break;
        case 8:
          Pointer<Double> dataPointer = data.cast<Double>();
          for (var i = 0; i < dataOut.size; i++) {
            dataOut.flat[i] = dataPointer[i];
          }
          break;
        default:
          throw "Only 32 and 64 bit types are supported.";
      }
    case H5T_class_t.INTEGER:
      switch (typeInfo.size){
        case 4:
          Pointer<Int32> dataPointer = data.cast<Int32>();
          for (var i = 0; i < dataOut.size; i++) {
            int value = dataPointer[i];
            dataOut.flat[i] = value.toDouble();
          }
          break;
        case 8:
          Pointer<Int64> dataPointer = data.cast<Int64>();
          for (var i = 0; i < dataOut.size; i++) {
            int value = dataPointer[i];
            dataOut.flat[i] = value.toDouble();
          }
          break;
        default:
          throw "Only 32 and 64 bit types are supported.";
      }
    case H5T_class_t.COMPOUND:
      // assume usage for imaginary numbers
      int nMembers = HDF5lib.H5T.getNMembers(typeInfo.nativeTypeId);
      List<CompoundMemberInfo> compoundMemberInfo = [];

      for (int i = 0; i < nMembers; i++) {
        String memberName = HDF5lib.H5T.getMemberName(typeInfo.nativeTypeId, i);

        int memberType = HDF5lib.H5T.getMemberType(typeInfo.nativeTypeId, i);
        TypeInfo memberTypeInfo = getTypeInfo(memberType);

        int offset = HDF5lib.H5T.getMemberOffset(typeInfo.nativeTypeId, i);

        compoundMemberInfo.add(CompoundMemberInfo(
            memberName, SpaceInfo(0, [], []), memberTypeInfo, offset));
      }
      if (compoundMemberInfo.length == 2){
        if (compoundMemberInfo[0].typeInfo.size == 8 &&
            compoundMemberInfo[1].typeInfo.size == 8 &&
            compoundMemberInfo[0].typeInfo.type == H5T_class_t.FLOAT &&
            compoundMemberInfo[1].typeInfo.type == H5T_class_t.FLOAT) {
          Pointer<Double> dataPointer = data.cast<Double>();
          for (var i = 0, j = 0; i < dataOut.size; i++, j += 2) {
            dataOut.flat[i] = readImaginary ? dataPointer[j + 1] : dataPointer[j];
          }
        } else {
          throw "Only 32 bit float types are supported.";
        }
      } else {
        throw "Only complex numbers are supported.";
      }
      
    default:
      throw "Only integer and float types are supported.";

  }

  HDF5lib.H5S.close(space.memSpaceId);
  HDF5lib.H5S.close(space.fileSpaceId);

  spaceInfo.dispose();
  typeInfo.dispose();

  calloc.free(data);
  logger.info("Data read from dataset $datasetId successfully");
  return dataOut;
}

({int memSpaceId, int fileSpaceId, List<int> outputDim}) hypersliceData(
    SpaceInfo spaceInfo, dynamic idx) {
  HDF5Bindings HDF5lib = HDF5Bindings();

  List<int> offset = [];
  List<int> count = [];
  List<int> outputDim = [];

  if (idx is! List) {
    idx = [idx];
  }

  for (int i = 0; i < spaceInfo.rank; i++) {
    if (i < idx.length) {
      if (idx[i] is int) {
        offset.add(idx[i]);
        count.add(1);
      } else if (idx[i] is Slice) {
        Slice sliceCpy = idx[i].getFormattedSlice(spaceInfo.dim[i]);
        if (sliceCpy.start <= sliceCpy.stop! &&
            sliceCpy.stop! <= spaceInfo.dim[i]) {
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
      count.add(spaceInfo.dim[i]);
      outputDim.add(spaceInfo.dim[i]);
    }
  }
  int memSpaceId = HDF5lib.H5S.createSimple(outputDim);
  int fileSpaceId = HDF5lib.H5S.createSimple(spaceInfo.dim);

  HDF5lib.H5S.selectHyperslab(fileSpaceId, offset, count);

  return (
    memSpaceId: memSpaceId,
    fileSpaceId: fileSpaceId,
    outputDim: outputDim
  );
}

void writeData(int datasetId, ndarray data) {
  logger.info("Writing data to dataset $datasetId");
  HDF5Bindings HDF5lib = HDF5Bindings();

  // Get dataset type information
  int typeId = HDF5lib.H5D.getType(datasetId);
  TypeInfo typeInfo = getTypeInfo(typeId);

  // Get dataset space information
  int spaceId = HDF5lib.H5D.getSpace(datasetId);
  SpaceInfo spaceInfo = getSpaceInfo(spaceId);

  // Validate data size matches dataset dimensions
  int expectedSize = 1;
  for (int dim in spaceInfo.dim) {
    expectedSize *= dim;
  }

  if (data.size != expectedSize) {
    spaceInfo.dispose();
    typeInfo.dispose();
    throw Exception(
      'Data size mismatch: expected $expectedSize elements but got ${data.size} elements'
    );
  }

  // Get pointer to Numd array's data based on dtype
  Pointer dataPtr;
  int h5TypeId;

  switch (data.dtype) {
    case DType.float32:
      if (typeInfo.type != H5T_class_t.FLOAT || typeInfo.size != 4) {
        spaceInfo.dispose();
        typeInfo.dispose();
        throw Exception(
          'Type mismatch: dataset expects ${typeInfo.type} size ${typeInfo.size}, but got float32'
        );
      }
      dataPtr = data.getDataPointer().cast<Float>();
      h5TypeId = HDF5lib.H5T.H5T_NATIVE_FLOAT;
      break;

    case DType.float64:
      if (typeInfo.type != H5T_class_t.FLOAT || typeInfo.size != 8) {
        spaceInfo.dispose();
        typeInfo.dispose();
        throw Exception(
          'Type mismatch: dataset expects ${typeInfo.type} size ${typeInfo.size}, but got float64'
        );
      }
      dataPtr = data.getDataPointer().cast<Double>();
      h5TypeId = HDF5lib.H5T.H5T_NATIVE_DOUBLE;
      break;

    case DType.int32:
      if (typeInfo.type != H5T_class_t.INTEGER || typeInfo.size != 4) {
        spaceInfo.dispose();
        typeInfo.dispose();
        throw Exception(
          'Type mismatch: dataset expects ${typeInfo.type} size ${typeInfo.size}, but got int32'
        );
      }
      dataPtr = data.getDataPointer().cast<Int32>();
      h5TypeId = HDF5lib.H5T.H5T_NATIVE_INT;
      break;

    case DType.int64:
      if (typeInfo.type != H5T_class_t.INTEGER || typeInfo.size != 8) {
        spaceInfo.dispose();
        typeInfo.dispose();
        throw Exception(
          'Type mismatch: dataset expects ${typeInfo.type} size ${typeInfo.size}, but got int64'
        );
      }
      dataPtr = data.getDataPointer().cast<Int64>();
      h5TypeId = HDF5lib.H5T.H5T_NATIVE_LLONG;
      break;

    case DType.complex64:
    case DType.complex128:
      spaceInfo.dispose();
      typeInfo.dispose();
      throw UnsupportedError(
        'Zero-copy write for complex types (${data.dtype}) is not yet supported. '
        'Numd library does not expose data pointers for complex arrays.'
      );
  }

  // Write data directly from Numd's memory buffer to HDF5 (ZERO-COPY!)
  int status = HDF5lib.H5D.write(
    datasetId,
    h5TypeId,
    H5S_ALL,
    H5S_ALL,
    H5P_DEFAULT,
    dataPtr
  );

  // Cleanup - dispose() methods handle closing the HDF5 resources
  spaceInfo.dispose();
  typeInfo.dispose();

  if (status < 0) {
    throw Exception('Failed to write data to dataset $datasetId (H5Dwrite returned $status)');
  }

  logger.info("Data written to dataset $datasetId successfully");
}
