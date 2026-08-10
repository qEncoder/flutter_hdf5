import 'package:hdf5/src/bindings/H5T.dart';
import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/c_to_dart_calls/attributes.dart';
import 'package:hdf5/src/c_to_dart_calls/type_info.dart';
import 'package:hdf5/src/c_to_dart_calls/space_info.dart';
import 'package:hdf5/src/utility/logging.dart';

import 'package:numd/numd.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

ndarray readData(datasetId, dynamic idx) {
  logger.info("Reading data from dataset $datasetId");
  HDF5Bindings HDF5lib = HDF5Bindings();

  int typeId = HDF5lib.H5D.getType(datasetId);
  int spaceId = HDF5lib.H5D.getSpace(datasetId);

  TypeInfo typeInfo = getTypeInfo(typeId);
  SpaceInfo spaceInfo = getSpaceInfo(spaceId);

  ({int memSpaceId, int fileSpaceId, List<int> outputDim}) space =
      hypersliceData(spaceInfo, idx);

  try {
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
          throw Exception("Only 32 and 64 bit integer types are supported.");
        }
        break;

      case H5T_class_t.COMPOUND:
        // Parse compound type members to determine if it's a complex number
        int nMembers = HDF5lib.H5T.getNMembers(typeInfo.nativeTypeId);

        if (nMembers != 2) {
          throw Exception(
              "Only complex numbers (2-member compounds) are supported. Found $nMembers members.");
        }

        List<CompoundMemberInfo> compoundMemberInfo = [];
        for (int i = 0; i < nMembers; i++) {
          String memberName =
              HDF5lib.H5T.getMemberName(typeInfo.nativeTypeId, i);
          int memberType = HDF5lib.H5T.getMemberType(typeInfo.nativeTypeId, i);
          TypeInfo memberTypeInfo = getTypeInfo(memberType);
          int offset = HDF5lib.H5T.getMemberOffset(typeInfo.nativeTypeId, i);

          compoundMemberInfo.add(CompoundMemberInfo(
              memberName, SpaceInfo(0, [], []), memberTypeInfo, offset));
        }

        // Validate complex type
        if (compoundMemberInfo[0].typeInfo.type != H5T_class_t.FLOAT ||
            compoundMemberInfo[1].typeInfo.type != H5T_class_t.FLOAT) {
          throw Exception("Complex type members must be floats.");
        }

        // Determine complex dtype based on precision
        if (compoundMemberInfo[0].typeInfo.size == 4 &&
            compoundMemberInfo[1].typeInfo.size == 4) {
          dtype = DType.complex64;
        } else if (compoundMemberInfo[0].typeInfo.size == 8 &&
            compoundMemberInfo[1].typeInfo.size == 8) {
          dtype = DType.complex128;
        } else {
          throw Exception(
              "Only float32 (complex64) and float64 (complex128) complex types are supported.");
        }

        // Use the native type ID for complex compound types
        h5TypeId = typeInfo.nativeTypeId;
        break;

      case H5T_class_t.STRING:

        H5T_cset_t cset = HDF5lib.H5T.getCSet(typeInfo.nativeTypeId);
        
        // only allow ASCII and UTF-8 character sets for string datasets
        if (cset != H5T_cset_t.ASCII && cset != H5T_cset_t.UTF8) {
          throw Exception("Unsupported character set for string dataset.");
        }

        final shape = space.outputDim.isEmpty ? [1] : space.outputDim;
        final nElem = shape.reduce((a, b) => a * b);
        final dataOut = ndarray.fromShape(shape, dtype: DType.string);


        if (HDF5lib.H5T.isVariableStr(typeInfo.nativeTypeId) > 0) {
          final buf = calloc<Pointer<Utf8>>(nElem);
          HDF5lib.H5D.read(datasetId, typeInfo.nativeTypeId,
              space.memSpaceId, space.fileSpaceId, H5P_DEFAULT, buf.cast());

          for (int i = 0; i < nElem; i++) {
            final p = buf[i];
            if (p == nullptr) {
              dataOut.flat.setStringFromPointer(i, nullptr.cast(), 0);
            } else {
              dataOut.flat.setStringFromPointer(i, p.cast(), p.length);
            }
          }

          HDF5lib.H5T.reclaim(typeInfo.nativeTypeId, space.memSpaceId, H5P_DEFAULT, buf.cast());
          calloc.free(buf);
        } else{
          throw Exception("Fixed-length string datasets are not yet supported. Please use variable-length (VLEN) strings.");
          // TEMPLATE FOR WHEN NEEDED
          // final sz  = typeInfo.size; 
          // final buf = calloc<Uint8>(sz * nElem);
          // HDF5lib.H5D.read(datasetId, typeInfo.nativeTypeId,
          //     space.memSpaceId, space.fileSpaceId, H5P_DEFAULT, buf.cast());

          // final pad = HDF5lib.H5T.getStrpad(typeInfo.nativeTypeId);
          // final bytes = buf.asTypedList(sz * nElem);

          // for (int i = 0; i < nElem; i++) {
          //   final start = i * sz;
          //   int len = sz;
          //   if (pad == H5T_STR_NULLTERM || pad == H5T_STR_NULLPAD) {
          //     while (len > 0 && bytes[start + len - 1] == 0) len--;
          //   } else {                                  // H5T_STR_SPACEPAD
          //     while (len > 0 && bytes[start + len - 1] == 0x20) len--;
          //   }
          //   dataOut.flat.setStringFromPointer(
          //       i, Pointer<Uint8>.fromAddress(buf.address + start).cast(), len);
          // }

          // calloc.free(buf);
        }
        
        return dataOut;
      default:
        throw Exception(
            "Unsupported HDF5 type class ${typeInfo.type} (size ${typeInfo.size}) "
            "for dataset $datasetId. Supported: integer, float, complex, and "
            "variable-length (VLEN) string.");
    }

    // Create Numd array with correct type and shape (allocates memory)
    // ⚠️ LIMITATION: Cannot handle datasets with zero-size dimensions (e.g., shape [0] or [5, 0, 3])
    // Root cause: Numd's fromShape() validates all dimensions must be > 0 (ndarray.dart:88-90)
    // Backend (xtensor) supports empty arrays, but Numd API does not expose this capability
    ndarray dataOut;
    if (space.outputDim.isEmpty) {
      dataOut = ndarray.fromShape([1], dtype: dtype);
    } else {
      dataOut = ndarray.fromShape(space.outputDim, dtype: dtype);
      // Note: This will throw Exception if any dimension in outputDim is 0
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
      case DType.complex64:
      case DType.complex128:
        // Complex types don't need casting, getDataPointer() returns correct type
        dataPtr = dataOut.getDataPointer();
        break;
      case DType.string:
        // Unreachable: string datasets are read via the VLEN branch, which
        // returns before this zero-copy path.
        throw StateError('string arrays are read via the VLEN path');
    }

    // HDF5 reads DIRECTLY into Numd's memory - TRUE ZERO-COPY!
    HDF5lib.H5D.read(datasetId, h5TypeId, space.memSpaceId, space.fileSpaceId,
        H5P_DEFAULT, dataPtr);

    logger.info(
        "Data read from dataset $datasetId successfully (zero-copy, dtype: $dtype)");
    return dataOut;
  } finally {
    // Cleanup resources regardless of success or failure
    HDF5lib.H5S.close(space.memSpaceId);
    HDF5lib.H5S.close(space.fileSpaceId);
    spaceInfo.dispose();
    typeInfo.dispose();
  }
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
        'Data size mismatch: expected $expectedSize elements but got ${data.size} elements');
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
            'Type mismatch: dataset expects ${typeInfo.type} size ${typeInfo.size}, but got float32');
      }
      dataPtr = data.getDataPointer().cast<Float>();
      h5TypeId = HDF5lib.H5T.H5T_NATIVE_FLOAT;
      break;

    case DType.float64:
      if (typeInfo.type != H5T_class_t.FLOAT || typeInfo.size != 8) {
        spaceInfo.dispose();
        typeInfo.dispose();
        throw Exception(
            'Type mismatch: dataset expects ${typeInfo.type} size ${typeInfo.size}, but got float64');
      }
      dataPtr = data.getDataPointer().cast<Double>();
      h5TypeId = HDF5lib.H5T.H5T_NATIVE_DOUBLE;
      break;

    case DType.int32:
      if (typeInfo.type != H5T_class_t.INTEGER || typeInfo.size != 4) {
        spaceInfo.dispose();
        typeInfo.dispose();
        throw Exception(
            'Type mismatch: dataset expects ${typeInfo.type} size ${typeInfo.size}, but got int32');
      }
      dataPtr = data.getDataPointer().cast<Int32>();
      h5TypeId = HDF5lib.H5T.H5T_NATIVE_INT;
      break;

    case DType.int64:
      if (typeInfo.type != H5T_class_t.INTEGER || typeInfo.size != 8) {
        spaceInfo.dispose();
        typeInfo.dispose();
        throw Exception(
            'Type mismatch: dataset expects ${typeInfo.type} size ${typeInfo.size}, but got int64');
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
          'Numd library does not expose data pointers for complex arrays.');

    case DType.string:
      spaceInfo.dispose();
      typeInfo.dispose();
      throw UnsupportedError(
          'Writing string datasets is not yet supported.');
  }

  // Write data directly from Numd's memory buffer to HDF5 (ZERO-COPY!)
  int status = HDF5lib.H5D
      .write(datasetId, h5TypeId, H5S_ALL, H5S_ALL, H5P_DEFAULT, dataPtr);

  // Cleanup - dispose() methods handle closing the HDF5 resources
  spaceInfo.dispose();
  typeInfo.dispose();

  if (status < 0) {
    throw Exception(
        'Failed to write data to dataset $datasetId (H5Dwrite returned $status)');
  }

  logger.info("Data written to dataset $datasetId successfully");
}
