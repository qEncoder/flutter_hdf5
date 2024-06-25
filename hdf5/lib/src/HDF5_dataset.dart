import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/HDF5_attributes.dart';
import 'package:hdf5/src/c_to_dart_calls/space_info.dart';
import 'package:hdf5/src/c_to_dart_calls/type_info.dart';
import 'package:hdf5/src/c_to_dart_calls/utility.dart';
import 'package:hdf5/src/c_to_dart_calls/dataset.dart';
import 'package:hdf5/src/HDF5_file.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:hdf5/src/utility/logging.dart';

class H5Dataset {
  final H5File file;
  final String fullName;
  final String name;

  late int ndim;
  late List<int> shape;

  late final int __datasetId;

  bool __closed = false;
  get datasetId => (__closed) ? -1 : __datasetId;

  late final AttributeMgr attr;

  H5Dataset(this.file, this.fullName) : name = fullName.split("/").last {
    logger.info("Opening dataset $fullName in file ${file.fileName}");
    Pointer<Uint8> namePtr = strToChar(fullName);

    __datasetId = HDF5Bindings().H5D.open(file.fileId, namePtr, H5P_DEFAULT);
    calloc.free(namePtr);

    attr = AttributeMgr(file, datasetId);

    int spaceId = HDF5Bindings().H5D.getSpace(datasetId);
    SpaceInfo spaceInfo = getSpaceInfo(spaceId);
    ndim = spaceInfo.rank;
    shape = spaceInfo.dim;
    spaceInfo.dispose();
    file.children.add(this);
  }

  void close() {
    if (__closed) return;

    __closed = true;
    HDF5Bindings().H5D.close(__datasetId);
  }

  void refresh() {
    HDF5Bindings().H5D.refresh(datasetId);

    int spaceId = HDF5Bindings().H5D.getSpace(datasetId);
    SpaceInfo spaceInfo = getSpaceInfo(spaceId);
    ndim = spaceInfo.rank;
    shape = spaceInfo.dim;
    spaceInfo.dispose();
  }

  String get dataType {
    // Returns the datatype of the dataset as a string representation
    int typeId = HDF5Bindings().H5D.getType(datasetId);
    TypeInfo typeInfo = getTypeInfo(typeId);
    String type = typeInfo.toString();
    typeInfo.dispose();
    return type;
  }

  H5D_layout_t get layout{
    int plistId = HDF5Bindings().H5D.getCreatePlist(datasetId);
    H5D_layout_t dsLayout =  HDF5Bindings().H5P.getLayout(plistId);
    HDF5Bindings().H5P.close(plistId);
    return dsLayout;
  }

    int get storageSize {
    // Returns the size of the dataset in bytes
    return HDF5Bindings().H5D.getStorageSize(datasetId);
  }

  FilterSettings getFilter(){
    int plistId = HDF5Bindings().H5D.getCreatePlist(datasetId);
    int nfilters = HDF5Bindings().H5P.getNFilters(plistId);
    
    if (nfilters == 0) {
      HDF5Bindings().H5P.close(plistId);
      return FilterSettings(0, [], 0);
    }

    TypeInfo typeInfo = getTypeInfo(HDF5Bindings().H5D.getType(datasetId));
    double compressionRatio = storageSize / shape.reduce((a, b) => a * b)/typeInfo.size;
    typeInfo.dispose();
    FilterSettings filter = HDF5Bindings().H5P.getFilter(plistId, 0, compressionRatio);
    HDF5Bindings().H5P.close(plistId);
    return filter;
  }

  List<int> getChunkSize(){
    if (layout != H5D_layout_t.CHUNKED) {
      return [];
    }
    int plistId = HDF5Bindings().H5D.getCreatePlist(datasetId);
    List<int> chunkSize = HDF5Bindings().H5P.getChunkSize(plistId);
    HDF5Bindings().H5P.close(plistId);
    return chunkSize;
  }

  dynamic getData() {
    return readData(datasetId, []);
  }

  dynamic operator [](dynamic idx) {
    return readData(datasetId, idx);
  }

  @override
  String toString() {
    return "Dataset :: $name";
  }
}
