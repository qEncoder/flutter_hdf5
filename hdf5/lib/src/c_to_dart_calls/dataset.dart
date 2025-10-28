
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

  // Handle complex numbers separately (they require special unpacking from COMPOUND types)
  if (typeInfo.type == H5T_class_t.COMPOUND) {
    return _readComplexData(
      datasetId,
      space,
      typeInfo,
      spaceInfo,
      readImaginary
    );
  }

  // Determine Numd dtype and HDF5 native type from dataset type
  DType dtype;
  int h5TypeId;

  switch (typeInfo.type) {
    case H5T_class_t.FLOAT:
      if (typeInfo.size == 4) {
        dtype = DType.float32;
        h5TypeId = HDF5lib.H5T.H5T_NATIVE_FLOAT;
      } else if (typeInfo.size == 8) {
        dtype = DType.float64;
        h5TypeId = HDF5lib.H5T.H5T_NATIVE_DOUBLE;
      } else {
        spaceInfo.dispose();
        typeInfo.dispose();
        HDF5lib.H5S.close(space.memSpaceId);
        HDF5lib.H5S.close(space.fileSpaceId);
        throw Exception("Only 32 and 64 bit float types are supported.");
      }
      break;

    case H5T_class_t.INTEGER:
      if (typeInfo.size == 4) {
        dtype = DType.int32;
        h5TypeId = HDF5lib.H5T.H5T_NATIVE_INT;
      } else if (typeInfo.size == 8) {
        dtype = DType.int64;
        h5TypeId = HDF5lib.H5T.H5T_NATIVE_LLONG;
      } else {
        spaceInfo.dispose();
        typeInfo.dispose();
        HDF5lib.H5S.close(space.memSpaceId);
        HDF5lib.H5S.close(space.fileSpaceId);
        throw Exception("Only 32 and 64 bit integer types are supported.");
      }
      break;

    default:
      spaceInfo.dispose();
      typeInfo.dispose();
      HDF5lib.H5S.close(space.memSpaceId);
      HDF5lib.H5S.close(space.fileSpaceId);
      throw Exception("Only integer and float types are supported.");
  }

  // Create Numd array with correct type and shape (allocates memory)
  ndarray dataOut;
  if (space.outputDim.isEmpty) {
    dataOut = ndarray.fromShape([1], dtype: dtype);
  } else {
    dataOut = ndarray.fromShape(space.outputDim, dtype: dtype);
  }

  // Get pointer to Numd's internal memory
  Pointer dataPtr;
  switch (dtype) {
    case DType.float32:
      dataPtr = dataOut.getDataPointer().cast<Float>();
      break;
    case DType.float64:
      dataPtr = dataOut.getDataPointer().cast<Double>();
      break;
    case DType.int32:
      dataPtr = dataOut.getDataPointer().cast<Int32>();
      break;
    case DType.int64:
      dataPtr = dataOut.getDataPointer().cast<Int64>();
      break;
    default:
      // Should never reach here due to earlier validation
      spaceInfo.dispose();
      typeInfo.dispose();
      HDF5lib.H5S.close(space.memSpaceId);
      HDF5lib.H5S.close(space.fileSpaceId);
      throw Exception("Unsupported dtype: $dtype");
  }

  // HDF5 reads DIRECTLY into Numd's memory - TRUE ZERO-COPY!
  HDF5lib.H5D.read(
    datasetId,
    h5TypeId,
    space.memSpaceId,
    space.fileSpaceId,
    H5P_DEFAULT,
    dataPtr
  );

  // Cleanup
  HDF5lib.H5S.close(space.memSpaceId);
  HDF5lib.H5S.close(space.fileSpaceId);
  spaceInfo.dispose();
  typeInfo.dispose();

  logger.info("Data read from dataset $datasetId successfully (zero-copy)");
  return dataOut;
}

// Helper function for reading complex numbers from HDF5 COMPOUND types
ndarray _readComplexData(
  int datasetId,
  ({int memSpaceId, int fileSpaceId, List<int> outputDim}) space,
  TypeInfo typeInfo,
  SpaceInfo spaceInfo,
  bool readImaginary
) {
  HDF5Bindings HDF5lib = HDF5Bindings();

  // Create output array (default float64 for complex data)
  ndarray dataOut = ndarray.fromShape([1]);
  if (space.outputDim.isNotEmpty) {
    dataOut = ndarray.fromShape(space.outputDim);
  }

  int size = typeInfo.size * dataOut.size;

  // Allocate buffer for reading compound data
  Pointer<Int8> data = calloc<Int8>(size);

  try {
    // Read compound data from HDF5
    HDF5lib.H5D.read(
      datasetId,
      typeInfo.nativeTypeId,
      space.memSpaceId,
      space.fileSpaceId,
      H5P_DEFAULT,
      data
    );

    // Parse compound type members
    int nMembers = HDF5lib.H5T.getNMembers(typeInfo.nativeTypeId);
    List<CompoundMemberInfo> compoundMemberInfo = [];

    for (int i = 0; i < nMembers; i++) {
      String memberName = HDF5lib.H5T.getMemberName(typeInfo.nativeTypeId, i);
      int memberType = HDF5lib.H5T.getMemberType(typeInfo.nativeTypeId, i);
      TypeInfo memberTypeInfo = getTypeInfo(memberType);
      int offset = HDF5lib.H5T.getMemberOffset(typeInfo.nativeTypeId, i);

      compoundMemberInfo.add(CompoundMemberInfo(
        memberName,
        SpaceInfo(0, [], []),
        memberTypeInfo,
        offset
      ));
    }

    // Validate and unpack complex numbers (2 float members)
    if (compoundMemberInfo.length == 2) {
      if (compoundMemberInfo[0].typeInfo.type == H5T_class_t.FLOAT &&
          compoundMemberInfo[1].typeInfo.type == H5T_class_t.FLOAT) {

        // Handle both complex64 (size 4) and complex128 (size 8)
        if (compoundMemberInfo[0].typeInfo.size == 4 && compoundMemberInfo[1].typeInfo.size == 4) {
          // Complex64 - single precision
          Pointer<Float> dataPointer = data.cast<Float>();
          for (var i = 0, j = 0; i < dataOut.size; i++, j += 2) {
            dataOut.flat[i] = readImaginary ? dataPointer[j + 1] : dataPointer[j];
          }
        } else if (compoundMemberInfo[0].typeInfo.size == 8 && compoundMemberInfo[1].typeInfo.size == 8) {
          // Complex128 - double precision
          Pointer<Double> dataPointer = data.cast<Double>();
          for (var i = 0, j = 0; i < dataOut.size; i++, j += 2) {
            dataOut.flat[i] = readImaginary ? dataPointer[j + 1] : dataPointer[j];
          }
        } else {
          throw Exception("Only float32 (complex64) and float64 (complex128) complex types are supported.");
        }
      } else {
        throw Exception("Complex type members must be floats.");
      }
    } else {
      throw Exception("Only complex numbers (2-member compounds) are supported.");
    }
  } finally {
    // Cleanup
    calloc.free(data);
    HDF5lib.H5S.close(space.memSpaceId);
    HDF5lib.H5S.close(space.fileSpaceId);
    spaceInfo.dispose();
    typeInfo.dispose();
  }

  logger.info("Complex data read from dataset $datasetId successfully");
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
