import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/c_to_dart_calls/attributes.dart';
import 'package:hdf5/src/c_to_dart_calls/type_info.dart';
import 'package:hdf5/src/c_to_dart_calls/space_info.dart';
import 'package:hdf5/src/utility/logging.dart';

import 'package:numd/numd.dart';

import 'dart:ffi';
import 'dart:typed_data';
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

  // Calculate total number of elements
  int totalElements = space.outputDim.isEmpty ? 1 : space.outputDim.reduce((a, b) => a * b);

  ndarray dataOut;

  // Optimized reading using TypedList (zero-copy view of C memory)
  switch (typeInfo.type) {
    case H5T_class_t.FLOAT:
      switch (typeInfo.size) {
        case 4:
          // Float32
          Pointer<Float> buffer = calloc<Float>(totalElements);
          HDF5lib.H5D.read(datasetId, HDF5lib.H5T.H5T_NATIVE_FLOAT, space.memSpaceId,
              space.fileSpaceId, H5P_DEFAULT, buffer);

          // Create typed view (no copy!)
          Float32List typedList = buffer.asTypedList(totalElements);

          // Convert to Numd array with proper reshaping
          dataOut = ndarray.fromList(
            List<double>.from(typedList),
            dtype: DType.float32
          );
          if (space.outputDim.isNotEmpty && space.outputDim.length > 1) {
            dataOut.reshape(space.outputDim);
          }

          calloc.free(buffer);
          break;

        case 8:
          // Float64
          Pointer<Double> buffer = calloc<Double>(totalElements);
          HDF5lib.H5D.read(datasetId, HDF5lib.H5T.H5T_NATIVE_DOUBLE, space.memSpaceId,
              space.fileSpaceId, H5P_DEFAULT, buffer);

          Float64List typedList = buffer.asTypedList(totalElements);

          dataOut = ndarray.fromList(
            List<double>.from(typedList),
            dtype: DType.float64
          );
          if (space.outputDim.isNotEmpty && space.outputDim.length > 1) {
            dataOut.reshape(space.outputDim);
          }

          calloc.free(buffer);
          break;

        default:
          throw Exception("Unsupported float size: ${typeInfo.size} bytes. Only 32-bit (4 bytes) and 64-bit (8 bytes) floats are supported.");
      }
      break;

    case H5T_class_t.INTEGER:
      switch (typeInfo.size) {
        case 4:
          // Int32
          Pointer<Int32> buffer = calloc<Int32>(totalElements);
          HDF5lib.H5D.read(datasetId, HDF5lib.H5T.H5T_NATIVE_INT, space.memSpaceId,
              space.fileSpaceId, H5P_DEFAULT, buffer);

          Int32List typedList = buffer.asTypedList(totalElements);

          dataOut = ndarray.fromList(
            List<int>.from(typedList),
            dtype: DType.int32
          );
          if (space.outputDim.isNotEmpty && space.outputDim.length > 1) {
            dataOut.reshape(space.outputDim);
          }

          calloc.free(buffer);
          break;

        case 8:
          // Int64
          Pointer<Int64> buffer = calloc<Int64>(totalElements);
          HDF5lib.H5D.read(datasetId, HDF5lib.H5T.H5T_NATIVE_LLONG, space.memSpaceId,
              space.fileSpaceId, H5P_DEFAULT, buffer);

          Int64List typedList = buffer.asTypedList(totalElements);

          dataOut = ndarray.fromList(
            List<int>.from(typedList),
            dtype: DType.int64
          );
          if (space.outputDim.isNotEmpty && space.outputDim.length > 1) {
            dataOut.reshape(space.outputDim);
          }

          calloc.free(buffer);
          break;

        default:
          throw Exception("Unsupported integer size: ${typeInfo.size} bytes. Only 32-bit (4 bytes) and 64-bit (8 bytes) integers are supported.");
      }
      break;

    case H5T_class_t.COMPOUND:
      // Compound types (primarily for complex numbers)
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

      // Check if this is a complex number (2 members, both float64)
      if (compoundMemberInfo.length == 2 &&
          compoundMemberInfo[0].typeInfo.size == 8 &&
          compoundMemberInfo[1].typeInfo.size == 8 &&
          compoundMemberInfo[0].typeInfo.type == H5T_class_t.FLOAT &&
          compoundMemberInfo[1].typeInfo.type == H5T_class_t.FLOAT) {

        // Read compound data
        int compoundSize = typeInfo.size * totalElements;
        Pointer<Int8> buffer = calloc<Int8>(compoundSize);
        HDF5lib.H5D.read(datasetId, typeInfo.nativeTypeId, space.memSpaceId,
            space.fileSpaceId, H5P_DEFAULT, buffer);

        Pointer<Double> doubleBuffer = buffer.cast<Double>();
        Float64List typedList = doubleBuffer.asTypedList(totalElements * 2);  // 2 doubles per complex number

        // Extract real or imaginary part
        List<double> extractedData = [];
        for (int i = 0; i < totalElements; i++) {
          extractedData.add(readImaginary ? typedList[i * 2 + 1] : typedList[i * 2]);
        }

        dataOut = ndarray.fromList(extractedData, dtype: DType.float64);
        if (space.outputDim.isNotEmpty && space.outputDim.length > 1) {
          dataOut.reshape(space.outputDim);
        }

        calloc.free(buffer);

      } else {
        throw Exception("Unsupported compound type. Only complex numbers (2 float64 members) are currently supported.");
      }
      break;

    default:
      throw Exception("Unsupported HDF5 type: ${typeInfo.type}. Supported types are FLOAT, INTEGER, and COMPOUND (for complex numbers).");
  }

  // Cleanup
  HDF5lib.H5S.close(space.memSpaceId);
  HDF5lib.H5S.close(space.fileSpaceId);
  spaceInfo.dispose();
  typeInfo.dispose();

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
