import 'package:flutter/material.dart';

import 'package:hdf5/hdf5.dart';
import 'package:numd/numd.dart';
import 'package:two_d_graph/graph_widget/graph_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class CoreToolsDataLoader {
  final H5File file;
  late final H5Group grpMain;
  final List<H5Dataset> rawMeasDS = [];
  final List<H5Dataset> proMeasDS = [];

  CoreToolsDataLoader(String fileName) : file = H5File.open(fileName) {
    grpMain = file.group;

    for (String ds in grpMain.datasets) {
      H5Dataset dataset = grpMain[ds];
      if (grpMain[ds].attr.attrNames.contains("DIMENSION_LIST")) {
        if (grpMain[ds].name.startsWith("RAW")) {
          rawMeasDS.add(dataset);
        } else {
          proMeasDS.add(dataset);
        }
      }
    }
  }
}

GraphData initializeGraphData(H5Dataset dataset) {
  List<ndarray> data = [];
  List<String> labels = [];
  List<String> units = [];

  data.add(dataset.getData());
  labels.add(dataset.attr['long_name']);
  units.add(dataset.attr['units']);

  List<dynamic> linkedDS = dataset.attr['DIMENSION_LIST'];
  for (var ds in linkedDS) {
    data.add(ds[0].getData());
    labels.add(ds[0].attr['long_name']);
    units.add(ds[0].attr['units']);
  }

  return GraphData(data, labels, units);
}

class _MyAppState extends State<MyApp> {
  late CoreToolsDataLoader ld;
  late List<GraphData> graphData1 = [];
  @override
  void initState() {
    super.initState();

    ld = CoreToolsDataLoader("test.hdf5");

    for (var i in ld.proMeasDS) {
      print("adding ${i}");
      var myData = initializeGraphData(i);
      graphData1.add(myData);
    }
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'This calls a native function through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text(
                  'sum(1, 2) = 20',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                FilledButton.tonal(
                  onPressed: () {
                    setState(() {
                      print("pressed");
                    });
                  },
                  child: Text('Click'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
