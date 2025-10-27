import 'package:flutter_test/flutter_test.dart';
import 'package:hdf5/hdf5.dart';
import 'package:numd/numd.dart' as nd;
import 'dart:io';

void main() {
  test('Zero-copy write and read for float64', () {
    final testFile = 'test_write_float64.h5';

    // Clean up any existing test file
    if (File(testFile).existsSync()) {
      File(testFile).deleteSync();
    }

    try {
      // Create test data
      final writeData = nd.ndarray.fromList([1.1, 2.2, 3.3, 4.4, 5.5], dtype: nd.DType.float64);

      // Create HDF5 file and dataset
      final file = H5File.create(testFile);
      final dataset = file.createDataset('test_data', writeData);
      file.close();

      // Read back the data
      final file2 = H5File.open(testFile);
      final dataset2 = file2.openDataset('test_data');
      final readData = dataset2.getData();
      file2.close();

      // Verify the data matches
      expect(readData.dtype, nd.DType.float64);
      expect(readData.size, 5);
      for (int i = 0; i < 5; i++) {
        expect((readData.flat[i] - writeData.flat[i]).abs(), lessThan(0.0001),
            reason: 'Element $i mismatch: expected ${writeData.flat[i]}, got ${readData.flat[i]}');
      }

      print('✓ Float64 zero-copy write/read test passed!');
    } finally {
      // Clean up
      if (File(testFile).existsSync()) {
        File(testFile).deleteSync();
      }
    }
  });

  test('Zero-copy write and read for int32', () {
    final testFile = 'test_write_int32.h5';

    // Clean up any existing test file
    if (File(testFile).existsSync()) {
      File(testFile).deleteSync();
    }

    try {
      // Create test data
      final writeData = nd.ndarray.fromList([10, 20, 30, 40, 50], dtype: nd.DType.int32);

      // Create HDF5 file and dataset
      final file = H5File.create(testFile);
      final dataset = file.createDataset('test_data', writeData);
      file.close();

      // Read back the data
      final file2 = H5File.open(testFile);
      final dataset2 = file2.openDataset('test_data');
      final readData = dataset2.getData();
      file2.close();

      // Verify the data matches
      expect(readData.dtype, nd.DType.float64); // HDF5 reads as float64
      expect(readData.size, 5);
      for (int i = 0; i < 5; i++) {
        expect(readData.flat[i].round(), writeData.flat[i].round(),
            reason: 'Element $i mismatch');
      }

      print('✓ Int32 zero-copy write/read test passed!');
    } finally {
      // Clean up
      if (File(testFile).existsSync()) {
        File(testFile).deleteSync();
      }
    }
  });
}
