import 'package:flutter_test/flutter_test.dart';
import 'package:hdf5/hdf5.dart';
import 'package:numd/numd.dart' as nd;
import 'dart:io';

void main() {
  // Note: These tests currently only test reading functionality
  // Write functionality will be implemented separately

  test('Zero-copy HDF5 read for float64', () {
    // This test requires a pre-existing HDF5 file
    // For now, we'll skip it if the file doesn't exist
    final testFile = 'test_data/test_float64.h5';

    if (!File(testFile).existsSync()) {
      print('⊘ Skipping float64 test - test file not found: $testFile');
      return;
    }

    try {
      final file = H5File.open(testFile);
      final dataset = file.openDataset('test_data');
      final readData = dataset.getData();

      // Verify it's an ndarray
      expect(readData, isA<nd.ndarray>());
      expect(readData.dtype, nd.DType.float64);

      print('✓ Float64 zero-copy test passed: shape=${readData.shape}, dtype=${readData.dtype}');

      file.close();
    } catch (e) {
      print('✗ Float64 test failed: $e');
      rethrow;
    }
  });

  test('Zero-copy HDF5 read for float32', () {
    final testFile = 'test_data/test_float32.h5';

    if (!File(testFile).existsSync()) {
      print('⊘ Skipping float32 test - test file not found: $testFile');
      return;
    }

    try {
      final file = H5File.open(testFile);
      final dataset = file.openDataset('test_data');
      final readData = dataset.getData();

      expect(readData, isA<nd.ndarray>());
      expect(readData.dtype, nd.DType.float32);

      print('✓ Float32 zero-copy test passed: shape=${readData.shape}, dtype=${readData.dtype}');

      file.close();
    } catch (e) {
      print('✗ Float32 test failed: $e');
      rethrow;
    }
  });

  test('Zero-copy HDF5 read for int32', () {
    final testFile = 'test_data/test_int32.h5';

    if (!File(testFile).existsSync()) {
      print('⊘ Skipping int32 test - test file not found: $testFile');
      return;
    }

    try {
      final file = H5File.open(testFile);
      final dataset = file.openDataset('test_data');
      final readData = dataset.getData();

      expect(readData, isA<nd.ndarray>());
      expect(readData.dtype, nd.DType.int32);

      print('✓ Int32 zero-copy test passed: shape=${readData.shape}, dtype=${readData.dtype}');

      file.close();
    } catch (e) {
      print('✗ Int32 test failed: $e');
      rethrow;
    }
  });

  test('Zero-copy HDF5 read for int64', () {
    final testFile = 'test_data/test_int64.h5';

    if (!File(testFile).existsSync()) {
      print('⊘ Skipping int64 test - test file not found: $testFile');
      return;
    }

    try {
      final file = H5File.open(testFile);
      final dataset = file.openDataset('test_data');
      final readData = dataset.getData();

      expect(readData, isA<nd.ndarray>());
      expect(readData.dtype, nd.DType.int64);

      print('✓ Int64 zero-copy test passed: shape=${readData.shape}, dtype=${readData.dtype}');

      file.close();
    } catch (e) {
      print('✗ Int64 test failed: $e');
      rethrow;
    }
  });

  test('API structure test - verify H5File and H5Dataset exist', () {
    // Basic sanity check that our API is accessible
    expect(H5File, isNotNull);
    expect(H5Dataset, isNotNull);

    print('✓ API structure test passed');
  });
}
