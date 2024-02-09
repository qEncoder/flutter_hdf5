import 'dart:ffi';

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

  List<String> attrNames = [];
  Pointer<Uint8> obj_name = strToChar(".");

  for (var i = 0; i < nAttr; i++) {
    int attrSize = HDF5lib.H5A.getNameByIdx(loc_id, obj_name, H5_INDEX_NAME,
        H5_ITER_INC, i, nullptr, 0, H5P_DEFAULT);
    if (attrSize < 0) throw "Error in attr size (negative)";

    Pointer<Uint8> name = calloc<Uint8>(attrSize + 1);
    int error = HDF5lib.H5A.getNameByIdx(loc_id, obj_name, H5_INDEX_NAME,
        H5_ITER_INC, i, name, attrSize + 1, H5P_DEFAULT);
    if (error < 0) throw "Error in obtaining attribute name";

    attrNames.add(charToString(name));
    calloc.free(name);
  }
  calloc.free(obj_name);

  return attrNames;
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

// TODO implement support for enum and array types.
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
    case H5T_STRING:
      if (HDF5lib.H5T.isVariableStr(typeInfo.nativeTypeId) > 0) {
        Pointer<Pointer<Uint8>> ptrAdressList =
            Pointer.fromAddress(myData.address);
        switch (spaceInfo.rank) {
          case 0:
            output = charToString(ptrAdressList[0]);
            HDF5lib.H5.freeMemory(ptrAdressList[0]);
            break;
          case 1:
            output = [];
            for (var i = 0; i < spaceInfo.dim[0]; i++) {
              output.add(charToString(ptrAdressList[i]));
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
            output = charToString(ptrCharData, maxLen: typeInfo.size);
            break;
          case 1:
            throw "Rank 1 Non-variable strings are currently not supported";
          default:
            throw H5RankException(spaceInfo.rank);
        }
      }
      break;
    case H5T_INTEGER:
      switch (typeInfo.size) {
        case 4:
          Pointer<Int32> integerList = myData.cast<Int32>();
          switch (spaceInfo.rank) {
            case 0:
              output = integerList[0];
              break;
            case 1:
              output = List<int>.empty(growable: true);
              for (var i = 0; i < spaceInfo.dim[0]; i++) {
                output.add(integerList[i]);
              }
              break;
            default:
              throw H5RankException(spaceInfo.rank);
          }
          break;
        case 8:
          Pointer<Int64> integerList = myData.cast<Int64>();
          switch (spaceInfo.rank) {
            case 0:
              output = integerList[0];
              break;
            case 1:
              output = List<int>.empty(growable: true);
              for (var i = 0; i < spaceInfo.dim[0]; i++) {
                output.add(integerList[i]);
              }
              break;
            default:
              throw H5RankException(spaceInfo.rank);
          }
          break;
        default:
          throw "Currenly only supporting signed int32 and int64.";
      }
      break;
    case H5T_FLOAT:
      switch (typeInfo.size) {
        case 4:
          Pointer<Float> floatList = Pointer.fromAddress(myData.address);
          switch (spaceInfo.rank) {
            case 0:
              output = floatList[0];
              break;
            case 1:
              output = List<double>.empty(growable: true);
              for (var i = 0; i < spaceInfo.dim[0]; i++) {
                output.add(floatList[i]);
              }
              break;
            default:
              throw H5RankException(spaceInfo.rank);
          }
          break;
        case 8:
          Pointer<Double> floatList = Pointer.fromAddress(myData.address);
          switch (spaceInfo.rank) {
            case 0:
              output = floatList[0];
              break;
            case 1:
              output = List<double>.empty(growable: true);
              for (var i = 0; i < spaceInfo.dim[0]; i++) {
                output.add(floatList[i]);
              }
              break;
            default:
              throw H5RankException(spaceInfo.rank);
          }
          break;
        default:
          throw "Currenly only supporting float32 and double64.";
      }
      break;
    case H5T_REFERENCE:
      Pointer<Int64> refenceList = myData.cast<Int64>();
      switch (spaceInfo.rank) {
        case 0:
          // how to be sure of the H5R_type_t? (should be H5R_OBJECT in most cases)
          // note that there is also an error in the docs, oapl_id not mentioned (observable in the source code).
          int objId = HDF5lib.H5R
              .deReference(file.fileId, H5P_DEFAULT, H5R_OBJECT, refenceList);

          int nameSize =
              HDF5lib.H5R.getName(objId, H5R_OBJECT, refenceList, nullptr, 0);
          if (nameSize < 0) throw "Error in getting name of the reference.";

          Pointer<Uint8> nameC = calloc<Uint8>(nameSize + 1);
          int error = HDF5lib.H5R
              .getName(objId, H5R_OBJECT, refenceList, nameC, nameSize + 1);
          if (error < 0) throw "Error in obtaining attribute name";

          String name = charToString(nameC);
          calloc.free(nameC);

          Pointer<Int32> objTypeC = calloc<Int32>(1);
          HDF5lib.H5R.getObjType(objId, H5R_OBJECT, refenceList, objTypeC);
          int objType = objTypeC.value;
          calloc.free(objTypeC);

          switch (objType) {
            case H5O_TYPE_GROUP:
              // group seems to close with the closing of the reference.
              HDF5lib.H5G.close(objId);
              output = file.openGroup(name);
              break;
            case H5O_TYPE_DATASET:
              // dataset seems to close with the closing of the reference.
              HDF5lib.H5D.close(objId);
              output = file.openDataset(name);
              break;
            default:
              throw "object type ${H5O_type_t[objType]} ($objType) not supported";
          }
          break;
        case 1:
          output = [];
          for (int i = 0; i < spaceInfo.dim[0]; i++) {
            Pointer dataPtr = refenceList.elementAt(i);
            output.add(
                cAttrDataToDart(file, dataPtr, typeInfo, SpaceInfo(0, [], [])));
          }
          break;
        default:
          throw H5RankException(spaceInfo.rank);
      }

    case H5T_ARRAY:
      throw "Array attributes currently not supported.";

    case H5T_VLEN:
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

    case H5T_COMPOUND:
      int nMembers = HDF5lib.H5T.getNMembers(typeInfo.nativeTypeId);
      List<CompoundMemberInfo> compoundMemberInfo = [];

      for (int i = 0; i < nMembers; i++) {
        Pointer<Uint8> memberNamePtr =
            HDF5lib.H5T.getMemberName(typeInfo.nativeTypeId, i);
        String memberName = charToString(memberNamePtr);
        HDF5lib.H5.freeMemory(memberNamePtr);

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
                myData.cast<Uint8>().elementAt(compoundMemberInfo[n].offset);
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
