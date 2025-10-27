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
