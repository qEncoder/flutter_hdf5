import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:hdf5/hdf5.dart';
import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/c_to_dart_calls/utility.dart';
import 'package:numd/numd.dart' as nd;

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    String fileName = "test/ds_1618824199687898284.hdf5";
    print("start");
    final attr = returnAllAttributes(fileName);
    print("done");
    print(attr);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

void read2D_data_test() {
  print("starting test");
  var H5 = HDF5Bindings();
  String file =
      "/Users/stephan/Library/Application Support/qdrive/data/3fa85f60-5617-4562-b3fc-2c963f66afa6/c0f34c86-8f37-4b64-8189-9a92647cb111/94e97f7f-304a-48ea-a462-2b66d111c945/1709557890995/Measurement.hdf5";
  int file_id = H5.H5F.open(file, H5F_ACC_SWMR_READ, H5P_DEFAULT);

  Pointer<Uint8> ds_name = strToChar("/counter");
  int ds_id = H5.H5D.open(file_id, ds_name, H5P_DEFAULT);
  calloc.free(ds_name);

  int space_id = H5.H5D.getSpace(ds_id);
  int data_type = H5.H5D.getType(ds_id);

  int ndims = H5.H5S.getSimpleExtentNdims(space_id);
  Pointer<Int64> dimPtr = calloc<Int64>(ndims);
  H5.H5S.getSimpleExtentDims(space_id, ndims);
  List<int> dims = List.from(dimPtr.asTypedList(ndims));
  calloc.free(dimPtr);

  List<int> outputDim = [31, 31];

  Pointer<Int64> dimMS = nd.intListToCArray(outputDim);
  int memSpaceId = H5.H5S.createSimple(outputDim);

  Pointer<Int64> dimDS = nd.intListToCArray(dims);
  int fileSpaceId = H5.H5S.createSimple(dims);

  Pointer<Int64> offsetDS = IntListToPtrArr([0, 0]);
  Pointer<Int64> countDS = IntListToPtrArr(outputDim);
  H5.H5S.selectHyperslab(fileSpaceId, [0, 0], outputDim);
  print("made hyperslab");
  int size = 1;
  for (int i in outputDim) {
    size *= i;
  }

  Pointer<Double> data = calloc<Double>(size);
  H5.H5D.read(ds_id, data_type, memSpaceId, fileSpaceId, H5P_DEFAULT, data);
  List<double> data_list = List.from(data.asTypedList(dims[0]));

  String data_str = "";
  for (int i = 0; i < outputDim[0]; i++) {
    data_str += data[i].toString() + " ";
  }
  data_str += "\n";
  for (int i = 0; i < dims[0]; i++) {
    data_str += data[i + outputDim[1]].toString() + " ";
  }
  print(data_str);

  calloc.free(data);

  H5.H5D.close(ds_id);
  H5.H5T.close(data_type);
  H5.H5S.close(space_id);
  H5.H5F.close(file_id);
}

void test_normal() {
  String file = "SLICE_TEST.h5";
  H5File h5file = H5File.open(file);
  H5Dataset dataset = h5file.openDataset("_1D");
  print(dataset.getData());
}

void test_zlib() {
  String file = "test.hdf5";
  H5File h5file = H5File.open(file);
  H5Dataset dataset = h5file.openDataset("read12");
  print(dataset.getData());
}

void test_S3_read() {
  String file =
      "https://s3.eu-central-1.amazonaws.com/qdrive-test-bucket/test_file/test.hdf5";
  String aws_region = "eu-central-1";
  String secret_id = "AKIAVRUVT3UJHHOM4GKA";
  String secret_key = " ";

  H5File h5file = H5File.openROS3(file, aws_region, secret_id, secret_key);
  H5Group group = h5file.group;
  print(group.datasets);
}



Map<String, dynamic> returnAllAttributes(String file){
  print("opening file ");
  H5File h5file = H5File.open(file);
  print("loading group");
  H5Group group = h5file.group;
  
  print("getting attributes from group");
  Map<String, dynamic> attributes = readAttributesFromGroup(group);

  h5file.close();

  return attributes;
}

Map<String, dynamic> readAttributesFromGroup(H5Group group){
  Map<String, dynamic> attributes = readAttributesfromAttrMgr(group.attr);

  // TODO with groups and datasets -- do not add when they are empty.

  // TODO this could cause problems in circular dependencies (this is allowed in HDF5)
  // TODO :: add check for this
  // TODO :: check if the name is the full path or current name
  for (String groupName in group.groups){
    H5Group subGroup = group[groupName];
    attributes[subGroup.name] = readAttributesFromGroup(subGroup);
    subGroup.close();
  }
  for (String datasetName in group.datasets){
    H5Dataset dataset = group[datasetName];
    attributes[dataset.name] = readAttributesfromAttrMgr(dataset.attr);
    dataset.close();
  }

  return attributes;
}

Map<String, dynamic> readAttributesfromAttrMgr(AttributeMgr attr){
  Map<String, dynamic> attributes = {};
  
  // netcdf4 specific attributes
  const List<String> netcdf4Attr = ["CLASS", "NAME", "REFERENCE_LIST", "DIMENSION_LIST", "_FillValue",
                                          "_Netcdf4Dimid", "_NCProperties", "_Netcdf4Coordinates", 
                                          "_param_index", "units", "long_name"];

  // TODO :: check if the attr value refers to other datasets/groups -- type checking
  // TODO :: when string check if json type or not.
  for (MapEntry<String, dynamic> attribute in attr){ 
    if (netcdf4Attr.contains(attribute.key)){
      continue;
    }
    attributes[attribute.key] = attribute.value;
  }
  return attributes;
}