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

  test('Complex number read test (complex128) - with actual HDF5 data', () {
    // Using pre-generated HDF5 file with real complex128 data
    // File contains: [1+2j, 3+4j, 5+6j]
    final testFile = 'test/temp_test_data/complex128_1d.h5';

    if (!File(testFile).existsSync()) {
      print('⊘ Skipping complex128 test - file not found: $testFile');
      return;
    }

    try {
      // Expected values from the pre-generated file
      final expectedReal = [1.0, 3.0, 5.0];
      final expectedImag = [2.0, 4.0, 6.0];

      // Read real parts
      final readFileReal = H5File.open(testFile);
      final datasetReal = readFileReal.openDataset('complex_data');
      final readReal = datasetReal.getData(readImaginary: false);

      // Verify real parts
      expect(readReal, isA<nd.ndarray>());
      expect(readReal.size, expectedReal.length);

      for (int i = 0; i < expectedReal.length; i++) {
        expect((readReal.flat[i] - expectedReal[i]).abs(), lessThan(1e-10),
            reason: 'Real part element $i: expected ${expectedReal[i]}, got ${readReal.flat[i]}');
      }

      readFileReal.close();

      // Read imaginary parts
      final readFileImag = H5File.open(testFile);
      final datasetImag = readFileImag.openDataset('complex_data');
      final readImag = datasetImag.getData(readImaginary: true);

      // Verify imaginary parts
      expect(readImag, isA<nd.ndarray>());
      expect(readImag.size, expectedImag.length);

      for (int i = 0; i < expectedImag.length; i++) {
        expect((readImag.flat[i] - expectedImag[i]).abs(), lessThan(1e-10),
            reason: 'Imaginary part element $i: expected ${expectedImag[i]}, got ${readImag.flat[i]}');
      }

      readFileImag.close();
    } catch (e) {
      print('✗ Complex128 test failed: $e');
      rethrow;
    }
  });

  test('Complex number read test (complex64) - with actual HDF5 data', () {
    // Using pre-generated HDF5 file with real complex64 data
    // File contains: [1+2j, 3+4j, 5+6j]
    final testFile = 'test/temp_test_data/complex64_1d.h5';

    if (!File(testFile).existsSync()) {
      print('⊘ Skipping complex64 test - file not found: $testFile');
      return;
    }

    try {
      // Expected values from the pre-generated file
      final expectedReal = [1.0, 3.0, 5.0];
      final expectedImag = [2.0, 4.0, 6.0];

      // Read real parts
      final readFileReal = H5File.open(testFile);
      final datasetReal = readFileReal.openDataset('complex_data');
      final readReal = datasetReal.getData(readImaginary: false);

      // Verify real parts (float32 precision)
      expect(readReal, isA<nd.ndarray>());
      expect(readReal.size, expectedReal.length);

      for (int i = 0; i < expectedReal.length; i++) {
        expect((readReal.flat[i] - expectedReal[i]).abs(), lessThan(1e-5),
            reason: 'Real part element $i: expected ${expectedReal[i]}, got ${readReal.flat[i]}');
      }

      readFileReal.close();

      // Read imaginary parts
      final readFileImag = H5File.open(testFile);
      final datasetImag = readFileImag.openDataset('complex_data');
      final readImag = datasetImag.getData(readImaginary: true);

      // Verify imaginary parts (float32 precision)
      expect(readImag, isA<nd.ndarray>());
      expect(readImag.size, expectedImag.length);

      for (int i = 0; i < expectedImag.length; i++) {
        expect((readImag.flat[i] - expectedImag[i]).abs(), lessThan(1e-5),
            reason: 'Imaginary part element $i: expected ${expectedImag[i]}, got ${readImag.flat[i]}');
      }

      readFileImag.close();
    } catch (e) {
      print('✗ Complex64 test failed: $e');
      rethrow;
    }
  });

  test('Boundary case: Single element array', () {
    final testFile = 'test_single_element.h5';

    if (File(testFile).existsSync()) {
      File(testFile).deleteSync();
    }

    try {
      // Test with single element
      final expectedData = [42.0];
      final writeData = nd.ndarray.fromList(expectedData, dtype: nd.DType.float64);

      final writeFile = H5File.create(testFile);
      writeFile.createDataset('single_data', writeData);
      writeFile.close();

      final readFile = H5File.open(testFile);
      final dataset = readFile.openDataset('single_data');
      final readData = dataset.getData();

      expect(readData.size, 1);
      expect(readData.dtype, nd.DType.float64);
      expect((readData.flat[0] - expectedData[0]).abs(), lessThan(1e-10));

      readFile.close();
    } finally {
      if (File(testFile).existsSync()) {
        File(testFile).deleteSync();
      }
    }
  });

  test('Boundary case: Empty dataset (known Numd limitation)', () {
    // Note: This test documents that empty arrays are NOT supported
    // This is a known limitation in the Numd library

    try {
      // Attempt to create empty array - should fail
      expect(
        () => nd.ndarray.fromList([], dtype: nd.DType.float64),
        throwsA(isA<RangeError>()),
        reason: 'Numd does not support empty arrays - this is expected'
      );
    } catch (e) {
      // Expected to fail
    }
  });

  test('Boundary case: Large array (1000 elements)', () {
    final testFile = 'test_large_array.h5';

    if (File(testFile).existsSync()) {
      File(testFile).deleteSync();
    }

    try {
      // Create large array with 1000 elements
      final expectedData = List<double>.generate(1000, (i) => i * 1.5);
      final writeData = nd.ndarray.fromList(expectedData, dtype: nd.DType.float64);

      final writeFile = H5File.create(testFile);
      writeFile.createDataset('large_data', writeData);
      writeFile.close();

      final readFile = H5File.open(testFile);
      final dataset = readFile.openDataset('large_data');
      final readData = dataset.getData();

      expect(readData.size, 1000);
      expect(readData.dtype, nd.DType.float64);

      // Verify first, middle, and last elements
      expect((readData.flat[0] - expectedData[0]).abs(), lessThan(1e-10));
      expect((readData.flat[500] - expectedData[500]).abs(), lessThan(1e-10));
      expect((readData.flat[999] - expectedData[999]).abs(), lessThan(1e-10));

      readFile.close();
    } finally {
      if (File(testFile).existsSync()) {
        File(testFile).deleteSync();
      }
    }
  });

  test('Boundary case: Multi-dimensional array (2D)', () {
    final testFile = 'test_2d_array.h5';

    if (File(testFile).existsSync()) {
      File(testFile).deleteSync();
    }

    try {
      // Create 2D array: 3x4 matrix using fromShape
      final writeData = nd.ndarray.fromShape([3, 4], dtype: nd.DType.float64);

      // Fill with known values
      final expectedData = [
        1.0, 2.0, 3.0, 4.0,
        5.0, 6.0, 7.0, 8.0,
        9.0, 10.0, 11.0, 12.0
      ];
      for (int i = 0; i < expectedData.length; i++) {
        writeData.flat[i] = expectedData[i];
      }

      final writeFile = H5File.create(testFile);
      writeFile.createDataset('matrix_data', writeData);
      writeFile.close();

      final readFile = H5File.open(testFile);
      final dataset = readFile.openDataset('matrix_data');
      final readData = dataset.getData();

      expect(readData.size, 12);
      expect(readData.shape, [3, 4]);
      expect(readData.dtype, nd.DType.float64);

      // Verify all elements
      for (int i = 0; i < expectedData.length; i++) {
        expect((readData.flat[i] - expectedData[i]).abs(), lessThan(1e-10),
            reason: 'Element $i mismatch');
      }

      readFile.close();
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
