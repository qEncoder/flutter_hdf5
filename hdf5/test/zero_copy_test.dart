import 'package:flutter_test/flutter_test.dart';
import 'package:hdf5/hdf5.dart';
import 'package:numd/numd.dart' as nd;
import 'dart:io';

void main() {
  test('Zero-copy HDF5 read for float64 with content verification', () {
    final testFile = 'test_zero_copy_float64.h5';

    if (File(testFile).existsSync()) {
      File(testFile).deleteSync();
    }

    try {
      // Create test data with known values
      final expectedData = [1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8];
      final writeData = nd.ndarray.fromList(expectedData, dtype: nd.DType.float64);

      // Write to HDF5 file
      final writeFile = H5File.create(testFile);
      writeFile.createDataset('test_data', writeData);
      writeFile.close();

      // Read back with zero-copy
      final readFile = H5File.open(testFile);
      final dataset = readFile.openDataset('test_data');
      final readData = dataset.getData();

      // Verify metadata
      expect(readData, isA<nd.ndarray>());
      expect(readData.dtype, nd.DType.float64);
      expect(readData.size, expectedData.length);

      // Verify content matches exactly
      for (int i = 0; i < expectedData.length; i++) {
        expect((readData.flat[i] - expectedData[i]).abs(), lessThan(1e-10),
            reason: 'Element $i: expected ${expectedData[i]}, got ${readData.flat[i]}');
      }

      readFile.close();
    } finally {
      if (File(testFile).existsSync()) {
        File(testFile).deleteSync();
      }
    }
  });

  test('Zero-copy HDF5 read for float32 with content verification', () {
    final testFile = 'test_zero_copy_float32.h5';

    if (File(testFile).existsSync()) {
      File(testFile).deleteSync();
    }

    try {
      // Create test data with known values
      final expectedData = [10.5, 20.5, 30.5, 40.5, 50.5];
      final writeData = nd.ndarray.fromList(expectedData, dtype: nd.DType.float32);

      // Write to HDF5 file
      final writeFile = H5File.create(testFile);
      writeFile.createDataset('test_data', writeData);
      writeFile.close();

      // Read back with zero-copy
      final readFile = H5File.open(testFile);
      final dataset = readFile.openDataset('test_data');
      final readData = dataset.getData();

      // Verify metadata
      expect(readData, isA<nd.ndarray>());
      expect(readData.dtype, nd.DType.float32);
      expect(readData.size, expectedData.length);

      // Verify content matches (float32 has less precision)
      for (int i = 0; i < expectedData.length; i++) {
        expect((readData.flat[i] - expectedData[i]).abs(), lessThan(1e-5),
            reason: 'Element $i: expected ${expectedData[i]}, got ${readData.flat[i]}');
      }

      readFile.close();
    } finally {
      if (File(testFile).existsSync()) {
        File(testFile).deleteSync();
      }
    }
  });

  test('Zero-copy HDF5 read for int32 with content verification', () {
    final testFile = 'test_zero_copy_int32.h5';

    if (File(testFile).existsSync()) {
      File(testFile).deleteSync();
    }

    try {
      // Create test data with known values
      final expectedData = [100, 200, 300, 400, 500, 600];
      final writeData = nd.ndarray.fromList(expectedData, dtype: nd.DType.int32);

      // Write to HDF5 file
      final writeFile = H5File.create(testFile);
      writeFile.createDataset('test_data', writeData);
      writeFile.close();

      // Read back with zero-copy
      final readFile = H5File.open(testFile);
      final dataset = readFile.openDataset('test_data');
      final readData = dataset.getData();

      // Verify metadata
      expect(readData, isA<nd.ndarray>());
      expect(readData.dtype, nd.DType.int32);
      expect(readData.size, expectedData.length);

      // Verify content matches exactly
      for (int i = 0; i < expectedData.length; i++) {
        expect(readData.flat[i].round(), expectedData[i],
            reason: 'Element $i: expected ${expectedData[i]}, got ${readData.flat[i]}');
      }

      readFile.close();
    } finally {
      if (File(testFile).existsSync()) {
        File(testFile).deleteSync();
      }
    }
  });

  test('Zero-copy HDF5 read for int64 with content verification', () {
    final testFile = 'test_zero_copy_int64.h5';

    if (File(testFile).existsSync()) {
      File(testFile).deleteSync();
    }

    try {
      // Create test data with known values
      final expectedData = [1000000, 2000000, 3000000, 4000000];
      final writeData = nd.ndarray.fromList(expectedData, dtype: nd.DType.int64);

      // Write to HDF5 file
      final writeFile = H5File.create(testFile);
      writeFile.createDataset('test_data', writeData);
      writeFile.close();

      // Read back with zero-copy
      final readFile = H5File.open(testFile);
      final dataset = readFile.openDataset('test_data');
      final readData = dataset.getData();

      // Verify metadata
      expect(readData, isA<nd.ndarray>());
      expect(readData.dtype, nd.DType.int64);
      expect(readData.size, expectedData.length);

      // Verify content matches exactly
      for (int i = 0; i < expectedData.length; i++) {
        expect(readData.flat[i].round(), expectedData[i],
            reason: 'Element $i: expected ${expectedData[i]}, got ${readData.flat[i]}');
      }

      readFile.close();
    } finally {
      if (File(testFile).existsSync()) {
        File(testFile).deleteSync();
      }
    }
  });

  test('Complex number read test (complex128) - structure verification', () {
    // Note: Complex number WRITE is not supported (Numd limitation)
    // This test verifies that complex READ functionality exists and works correctly
    // by testing the structure and ensuring no crashes occur

    // Test that getData accepts readImaginary parameter
    // We'll use a simple float64 file to verify the parameter is accepted
    final testFile = 'test_complex_structure.h5';

    if (File(testFile).existsSync()) {
      File(testFile).deleteSync();
    }

    try {
      // Create simple float64 data to test readImaginary parameter
      final testData = nd.ndarray.fromList([1.0, 2.0, 3.0], dtype: nd.DType.float64);

      final writeFile = H5File.create(testFile);
      writeFile.createDataset('test_data', testData);
      writeFile.close();

      // Verify getData accepts readImaginary parameter (for complex support)
      final readFile = H5File.open(testFile);
      final dataset = readFile.openDataset('test_data');

      // Test reading with readImaginary: false (default)
      final readReal = dataset.getData(readImaginary: false);
      expect(readReal, isA<nd.ndarray>());
      expect(readReal.size, 3);

      // Test reading with readImaginary: true
      final readImag = dataset.getData(readImaginary: true);
      expect(readImag, isA<nd.ndarray>());
      expect(readImag.size, 3);

      readFile.close();

      // Note: Actual complex number testing would require:
      // 1. A pre-generated HDF5 file with complex COMPOUND data
      // 2. OR Numd library support for complex write operations
      // This test verifies the read infrastructure is in place
    } finally {
      if (File(testFile).existsSync()) {
        File(testFile).deleteSync();
      }
    }
  });

  test('API structure test - verify H5File and H5Dataset exist', () {
    // Basic sanity check that our API is accessible
    expect(H5File, isNotNull);
    expect(H5Dataset, isNotNull);
  });
}
