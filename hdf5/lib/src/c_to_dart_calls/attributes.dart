import 'dart:ffi';
import 'dart:typed_data';

import 'package:hdf5/src/HDF5_file.dart';
import 'package:hdf5/src/bindings/H5T.dart';
import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/c_to_dart_calls/error.dart';
import 'package:hdf5/src/c_to_dart_calls/utility.dart';
import 'package:hdf5/src/c_to_dart_calls/type_info.dart';
import 'package:hdf5/src/c_to_dart_calls/space_info.dart';

import 'package:ffi/ffi.dart';

getAttrNames(int loc_id) {
  HDF5Bindings HDF5lib = HDF5Bindings();

  int nAttr = HDF5lib.H5A.getNumAttrs(loc_id);
  return List.generate(nAttr, (i) => HDF5lib.H5A.getNameByIdx(loc_id, i));
}

class CompoundMemberInfo {
  String name;
  SpaceInfo spaceInfo;
  TypeInfo typeInfo;
  int offset;

  CompoundMemberInfo(this.name, this.spaceInfo, this.typeInfo, this.offset);

  void dispose() {
    typeInfo.dispose();
    spaceInfo.dispose();
  }
}

// TODO implement support for array types.
dynamic readAttr(H5File file, int objId, String name) {
  HDF5Bindings HDF5lib = HDF5Bindings();

  Pointer<Uint8> namePtr = strToChar(name);
  int attrId = HDF5lib.H5A.open(objId, namePtr, H5P_DEFAULT);
  int typeId = HDF5lib.H5A.getType(attrId);
  int spaceId = HDF5lib.H5A.getSpace(attrId);

  TypeInfo typeInfo = getTypeInfo(typeId);
  SpaceInfo spaceInfo = getSpaceInfo(spaceId);

  calloc.free(namePtr);

  int size = typeInfo.size;
  for (int i in spaceInfo.dim) {
    size *= i;
  }

  Pointer myData = calloc<Uint8>(size);
  HDF5lib.H5A.read(attrId, typeInfo.nativeTypeId, myData);

  dynamic output = cAttrDataToDart(file, myData, typeInfo, spaceInfo);
  calloc.free(myData);
  typeInfo.dispose();
  spaceInfo.dispose();
  HDF5lib.H5A.close(attrId);
  return output;
}

dynamic cAttrDataToDart(
    H5File file, Pointer myData, TypeInfo typeInfo, SpaceInfo spaceInfo) {
  HDF5Bindings HDF5lib = HDF5Bindings();

  dynamic output;
  switch (typeInfo.type) {
    case H5T_class_t.STRING:
      H5T_cset_t cset = HDF5lib.H5T.getCSet(typeInfo.nativeTypeId);
      if (HDF5lib.H5T.isVariableStr(typeInfo.nativeTypeId) > 0) {
        Pointer<Pointer<Uint8>> ptrAdressList =
            Pointer.fromAddress(myData.address);
        switch (spaceInfo.rank) {
          case 0:
            output = charToString(ptrAdressList[0], cset: cset);
            HDF5lib.H5.freeMemory(ptrAdressList[0]);
            break;
          case 1:
            output = [];
            for (var i = 0; i < spaceInfo.dim[0]; i++) {
              output.add(charToString(ptrAdressList[i], cset: cset));
              HDF5lib.H5.freeMemory(ptrAdressList[i]);
            }
            break;
          default:
            throw H5RankException(spaceInfo.rank);
        }
      } else {
        switch (spaceInfo.rank) {
          case 0:
            Pointer<Uint8> ptrCharData = Pointer.fromAddress(myData.address);
            output = charToString(ptrCharData, maxLen: typeInfo.size, cset: cset);
            break;
          case 1:
            throw "Rank 1 Non-variable strings are currently not supported";
          default:
            throw H5RankException(spaceInfo.rank);
        }
      }
      break;
    case H5T_class_t.INTEGER || H5T_class_t.BITFIELD:
      // bitfield is interpreted as integer ...
      int dataSize = getNElem(spaceInfo.dim);
      switch (typeInfo.size) {
        case 1:
          Int8List integerList = myData.cast<Int8>().asTypedList(dataSize);
          output = cPtrToFlutterObj<Int8List, int>(integerList, spaceInfo.dim);
          break;
        case 2:
          Int16List integerList = myData.cast<Int16>().asTypedList(dataSize);
          output = cPtrToFlutterObj<Int16List, int>(integerList, spaceInfo.dim);
          break;
        case 4:
          Int32List integerList = myData.cast<Int32>().asTypedList(dataSize);
          output = cPtrToFlutterObj<Int32List, int>(integerList, spaceInfo.dim);
          break;
        case 8:
          Int64List integerList = myData.cast<Int64>().asTypedList(dataSize);
          output = cPtrToFlutterObj<Int64List, int>(integerList, spaceInfo.dim);
          break;
        default:
          throw "Currenly only supporting signed int32 and int64.";
      }
      break;
    case H5T_class_t.FLOAT:
      int dataSize = getNElem(spaceInfo.dim);
      switch (typeInfo.size) {
        case 4:
          Float32List floatList = myData.cast<Float>().asTypedList(dataSize);
          output = cPtrToFlutterObj<Float32List, double>(floatList, spaceInfo.dim);
          break;
        case 8:
          Float64List floatList = myData.cast<Double>().asTypedList(dataSize);
          output = cPtrToFlutterObj<Float64List, double>(floatList, spaceInfo.dim);
          break;
        default:
          throw "Currenly only supporting float32 and double64.";
      }
      break;
    case H5T_class_t.REFERENCE:
      Pointer<Int64> referenceList = myData.cast<Int64>();
      switch (spaceInfo.rank) {
        case 0:
          int objId = HDF5lib.H5R.deReference(file.fileId, referenceList);
          String name = HDF5lib.H5R.getName(objId, referenceList);

          H5O_type_t objType = HDF5lib.H5R.getObjType(objId, referenceList);

          switch (objType) {
            case H5O_type_t.GROUP:
              // group seems to close with the closing of the reference.
              HDF5lib.H5G.close(objId);
              output = file.openGroup(name);
              break;
            case H5O_type_t.DATASET:
              // dataset seems to close with the closing of the reference.
              HDF5lib.H5D.close(objId);
              output = file.openDataset(name);
              break;
            default:
              throw "object type ${objType.string} (${objType.value}) not supported";
          }
          break;
        case 1:
          output = [];
          for (int i = 0; i < spaceInfo.dim[0]; i++) {
            Pointer dataPtr = referenceList.elementAt(i);
            output.add(
                cAttrDataToDart(file, dataPtr, typeInfo, SpaceInfo(0, [], [])));
          }
          break;
        default:
          throw H5RankException(spaceInfo.rank);
      }

    case H5T_class_t.ENUM:
      Map enumDict = {};

      int nMembers = HDF5lib.H5T.getNMembers(typeInfo.nativeTypeId);
      TypeInfo enumTypeInfo =
          getTypeInfo(HDF5lib.H5T.getSuper(typeInfo.nativeTypeId));
      SpaceInfo enumSpaceInfo = SpaceInfo(0, [], []);

      for (int i = 0; i < nMembers; i++) {
        String enumValue = HDF5lib.H5T.getMemberName(typeInfo.nativeTypeId, i);

        Pointer enumKeyPtr = calloc<Uint8>(enumTypeInfo.size);
        HDF5lib.H5T.getMemberValue(typeInfo.nativeTypeId, i, enumKeyPtr);
        var enumKey =
            cAttrDataToDart(file, enumKeyPtr, enumTypeInfo, enumSpaceInfo);
        calloc.free(enumKeyPtr);

        enumDict[enumKey] = enumValue;
      }
      enumTypeInfo.dispose();
      enumSpaceInfo.dispose();

      var value = cAttrDataToDart(file, myData, enumTypeInfo, enumSpaceInfo);
      return enumDict[value];

    case H5T_class_t.ARRAY:
      throw "Array attributes currently not supported.";

    case H5T_class_t.VLEN:
      output = [];
      Pointer<hvl_t> dataPtr = Pointer.fromAddress(myData.address);
      TypeInfo VLEN_TYPE =
          getTypeInfo(HDF5lib.H5T.getSuper(typeInfo.nativeTypeId));

      for (int i = 0; i < spaceInfo.dim[0]; i++) {
        SpaceInfo VLEN_SPACE = SpaceInfo(1, [dataPtr[i].len], [dataPtr[i].len]);
        output.add(
            cAttrDataToDart(file, dataPtr[i].p.cast(), VLEN_TYPE, VLEN_SPACE));
      }

      HDF5lib.H5T.reclaim(
          typeInfo.nativeTypeId, spaceInfo.spaceId, H5P_DEFAULT, dataPtr);
      VLEN_TYPE.dispose();
      break;

    case H5T_class_t.COMPOUND:
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

      switch (spaceInfo.rank) {
        case 0:
          Map<String, dynamic> compoundData = {};
          for (int n = 0; n < nMembers; n++) {
            Pointer dataPtr =
                myData.cast<Uint8>() + compoundMemberInfo[n].offset;
            compoundData[compoundMemberInfo[n].name] = cAttrDataToDart(
                file,
                dataPtr,
                compoundMemberInfo[n].typeInfo,
                compoundMemberInfo[n].spaceInfo);
          }
          output = compoundData;
          break;
        case 1:
          output = [];
          for (int i = 0; i < spaceInfo.dim[0]; i++) {
            Pointer<Uint8> shiftedDataPtr =
                myData.cast<Uint8>().elementAt(typeInfo.size * i);
            Map<String, dynamic> compoundData = {};
            for (int n = 0; n < nMembers; n++) {
              Pointer dataPtr =
                  shiftedDataPtr.elementAt(compoundMemberInfo[n].offset);
              compoundData[compoundMemberInfo[n].name] = cAttrDataToDart(
                  file,
                  dataPtr,
                  compoundMemberInfo[n].typeInfo,
                  compoundMemberInfo[n].spaceInfo);
            }
            output.add(compoundData);
          }

          break;
        default:
          throw H5RankException(spaceInfo.rank);
      }

      for (var cMI in compoundMemberInfo) {
        cMI.dispose();
      }
      break;
    default:
      throw H5TTypeException(typeInfo.type);
  }

  return output;
}

dynamic cPtrToFlutterObj<T1 extends TypedDataList, T2>(T1 pointerList, List<int> dims){
  if (dims.length == 0) {
    return pointerList[0] as T2;
  } else {
    return buildMultiDimensionalList<T1, T2>(pointerList, dims);
  }
}

List<dynamic> buildMultiDimensionalList<T1 extends TypedDataList, T2>(T1 flatList, List<int> dims) {
  dynamic build(List<int> dims, int index) {
    if (dims.length == 1) {
      return flatList.sublist(index, index + dims[0]);
    }else {
      int step = dims.skip(1).reduce((a, b) => a * b);
      List<dynamic> result = [];
      for (int i = 0; i < dims[0]; i++) {
        result.add(build(dims.sublist(1), index + i * step));
      }
      return result;
    }
  }

  return build(dims, 0);
}

int getNElem(List<int> shape){
  if (shape.length == 0) {
    return 1;
  } else {
    return shape.reduce((a, b) => a * b);
  }
}