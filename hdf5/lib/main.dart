import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:hdf5/hdf5.dart';
import 'package:hdf5/src/bindings/HDF5_bindings.dart';
import 'package:hdf5/src/c_to_dart_calls/dataset.dart';
import 'package:hdf5/src/c_to_dart_calls/utility.dart';
import 'package:numd/numd.dart' as nd;
void main() async {
    // String fileName = "/Users/stephan/Library/Application Support/qdrive/data/3fa85f60-5617-4562-b3fc-2c963f66afa6/f49ab8c7-8a2e-481e-80d0-8c2a8e479519/7e9aa8b4-bd7f-4172-b692-fd9744429680/1709565700113/Measurement.hdf5";

    //   H5File file = H5File.open(fileName);
    //   H5Dataset dataset = file.openDataset("/counter");
      
    // for (int i in nd.Range(1)){
    //   // read2D_data_test();
    //   dataset.refresh();
    //   test2D_data_lib_functions(dataset);
    // }
    // dataset.dispose();

    //   print('waiting a bit');
    //   // sleep for 1 second
    //   await Future.delayed(const Duration(seconds: 1));

    // }
  // await Isolate.run(() => isolate_function());
  test_S3_read();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState(){
    super.initState();
    
    // print('opening file');
    // // H5File file = H5File.open("/Users/stephan/Library/Application Support/qdrive/data/3fa85f60-5617-4562-b3fc-2c963f66afa6/7fa3f215-5cf8-4dcb-9a50-1d6849e6434d/37540f8c-f706-4fff-89e4-4eb3286d503a/1709538060761/Measurement.hdf5");
    // // H5Dataset dataset = file.openDataset("/counter");
    // var H5 = HDF5Bindings();
    // String file = "/Users/stephan/Library/Application Support/qdrive/data/3fa85f60-5617-4562-b3fc-2c963f66afa6/7fa3f215-5cf8-4dcb-9a50-1d6849e6434d/37540f8c-f706-4fff-89e4-4eb3286d503a/1709538060761/Measurement.hdf5";
    // Pointer<Uint8> file_name = strToChar(file);
    // int file_id = H5.H5F.open(file_name, H5F_ACC_SWMR_READ, H5P_DEFAULT);
    // calloc.free(file_name);

    // Pointer<Uint8> ds_name = strToChar("/counter");
    // int ds_id = H5.H5D.open(file_id, ds_name, H5P_DEFAULT);
    // calloc.free(ds_name);
    
    // int space_id = H5.H5D.getSpace(ds_id);
    // int data_type = H5.H5D.getType(ds_id);

    // int ndims = H5.H5S.getSimpleExtentNdims(space_id);
    // Pointer<Int64> dimPtr = calloc<Int64>(ndims);
    // H5.H5S.getSimpleExtentDims(space_id, dimPtr, nullptr);
    // List<int> dims = List.from(dimPtr.asTypedList(ndims));
    // calloc.free(dimPtr);

    // Pointer<Double> data = calloc<Double>(dims[0]);
    // H5.H5D.read(ds_id, data_type, H5S_ALL, H5S_ALL, H5P_DEFAULT, data);
    // // List<double> data_list = List.from(data.asTypedList(dims[0]));

    // String data_str = "";
    // for (int i = 0; i < dims[0]; i++) {
    //   data_str += data[i].toString() + " ";
    // }
    // print(data_str);

    // calloc.free(data);
    // // print(data_list);

    // H5.H5D.close(ds_id);
    // H5.H5T.close(data_type);
    // H5.H5S.close(space_id);
    // H5.H5F.close(file_id);
    
    
    // print('file opened');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    print('opening file');
    // H5File file = H5File.open("test.hdf5");
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
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

void read2D_data_test(){
  print("starting test");
  var H5 = HDF5Bindings();
    String file = "/Users/stephan/Library/Application Support/qdrive/data/3fa85f60-5617-4562-b3fc-2c963f66afa6/c0f34c86-8f37-4b64-8189-9a92647cb111/94e97f7f-304a-48ea-a462-2b66d111c945/1709557890995/Measurement.hdf5";
    Pointer<Uint8> file_name = strToChar(file);
    int file_id = H5.H5F.open(file_name, H5F_ACC_SWMR_READ, H5P_DEFAULT);
    calloc.free(file_name);

    Pointer<Uint8> ds_name = strToChar("/counter");
    int ds_id = H5.H5D.open(file_id, ds_name, H5P_DEFAULT);
    calloc.free(ds_name);
    
    int space_id = H5.H5D.getSpace(ds_id);
    int data_type = H5.H5D.getType(ds_id);

    int ndims = H5.H5S.getSimpleExtentNdims(space_id);
    Pointer<Int64> dimPtr = calloc<Int64>(ndims);
    H5.H5S.getSimpleExtentDims(space_id, dimPtr, nullptr);
    List<int> dims = List.from(dimPtr.asTypedList(ndims));
    calloc.free(dimPtr);

    List<int> outputDim = [31, 31];

    Pointer<Int64> dimMS = nd.intListToCArray(outputDim);
    int memSpaceId =  H5.H5S.createSimple(outputDim.length, dimMS, nullptr);

    Pointer<Int64> dimDS = nd.intListToCArray(dims);
    int fileSpaceId = H5.H5S.createSimple(ndims, dimDS, nullptr);

    Pointer<Int64> offsetDS = IntListToPtrArr([0,0]);
    Pointer<Int64> countDS = IntListToPtrArr(outputDim);
    H5.H5S.selectHyperslab(fileSpaceId, H5S_SELECT_SET, offsetDS, nullptr, countDS, nullptr);
    print("made hyperslab");
    int size = 1;
    for (int i in outputDim){
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

void isolate_function() async{
    String fileName = "/Users/stephan/Library/Application Support/qdrive/data/3fa85f60-5617-4562-b3fc-2c963f66afa6/f49ab8c7-8a2e-481e-80d0-8c2a8e479519/7e9aa8b4-bd7f-4172-b692-fd9744429680/1709565700113/Measurement.hdf5";

      H5File file = H5File.open(fileName);
      H5Dataset dataset = file.openDataset("/counter");
      
    for (int i in nd.Range(10)){
      // read2D_data_test();
      dataset.refresh();
      test2D_data_lib_functions(dataset);

      print('waiting a bit');
      // sleep for 1 second
      await Future.delayed(const Duration(seconds: 1));

    }
}

void test2D_data_lib_functions(H5Dataset dataset){
      
      print(dataset.attr.attrNames);
      print(dataset.attr["__cursor"]);
      print(dataset.attr["__shape"]);
      var out = dataset[[nd.Slice(0, 30), nd.Slice(0,30)]];
      print(out[[0,0]]);

}

void test_S3_read(){
  String file = "https://s3.eu-central-1.amazonaws.com/qdrive-test-bucket/test_file/test.hdf5";
  String aws_region = "eu-central-1";
  String secret_id = "AKIAVRUVT3UJHHOM4GKA";
  String secret_key = "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";

  H5File h5file = H5File.openROS3(file, aws_region, secret_id, secret_key);
  H5Group group = h5file.group;
  print(group.datasets);

}