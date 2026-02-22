# flutter_hdf5

HDF5 library for Dart and Flutter with zero-copy data transfer.

## What It Does

This library lets you read and write HDF5 files from Flutter apps. It uses zero-copy operations where possible, meaning data goes directly between HDF5 and NumD arrays without intermediate buffers.

Key features:
- Read/write HDF5 files locally
- Access remote files via AWS S3 (ROS3 driver)
- Zero-copy data transfer with NumD arrays
- Support for groups, datasets, and attributes
- Slicing and hyperslab selection
- Complex number support (complex64, complex128)
- Chunked and compressed datasets

## Installation

```yaml
dependencies:
  hdf5:
    git:
      url: https://github.com/qEncoder/flutter_hdf5.git
      ref: dev
      path: hdf5
```

## Quick Start

```dart
import 'package:hdf5/hdf5.dart';
import 'package:numd/numd.dart';

// Open a file
final file = H5File.open('data.h5');

// Navigate to a dataset
final dataset = file.openDataset('/measurements/temperature');

// Read data as NumD array
final data = dataset.getData();
print('Shape: ${data.shape}');
print('Mean: ${mean(data)}');

// Clean up
file.close();
```

## Opening Files

```dart
// Read-only (default)
final file = H5File.open('data.h5');

// Create new file (overwrites existing)
final file = H5File.create('new_file.h5');

// Create with exclusive flag (fails if file exists)
final file = H5File.create('new_file.h5', flags: H5F_ACC_EXCL);

// Remote file via S3
final file = H5File.openROS3(
  'https://bucket.s3.region.amazonaws.com/data.h5',
  'us-east-1',
  'ACCESS_KEY_ID',
  'SECRET_ACCESS_KEY',
);
```

Always call `file.close()` when done.

## Working with Groups

```dart
final file = H5File.open('data.h5');

// Open root group
final root = file.group;

// List contents
print('Groups: ${root.groups}');
print('Datasets: ${root.datasets}');

// Navigate using subscript
final subgroup = root['measurements'];
final dataset = subgroup['temperature'];

// Or open directly
final dataset = file.openDataset('/measurements/temperature');
final group = file.openGroup('/measurements/');
```

## Reading Datasets

```dart
final dataset = file.openDataset('/data');

// Properties
print('Shape: ${dataset.shape}');
print('Dimensions: ${dataset.ndim}');
print('Type: ${dataset.dataType}');
print('Layout: ${dataset.layout}');
print('Storage size: ${dataset.storageSize} bytes');

// Read all data
final data = dataset.getData();

// Read with slicing
final slice = dataset.getSlices([Slice(0, 10), Slice(5, 15)]);

// Or use subscript notation
final slice = dataset[[Slice(0, 10), 5]];
```

## Writing Datasets

```dart
final file = H5File.create('output.h5');

// Create array
final data = ndarray.fromShape([100, 100], dtype: DType.float64);

// Create dataset and write
final dataset = file.createDataset('/measurements', data);

// Write to existing dataset
dataset.setData(newData);

file.close();
```

## Data Types

| HDF5 Type | NumD Type |
|-----------|-----------|
| 32-bit float | `DType.float32` |
| 64-bit float | `DType.float64` |
| 32-bit int | `DType.int32` |
| 64-bit int | `DType.int64` |
| complex64 | `DType.complex64` |
| complex128 | `DType.complex128` |

Types are automatically matched between HDF5 and NumD.

## Slicing

```dart
final dataset = file.openDataset('/data');  // shape: [100, 50, 20]

// Single index (reduces dimension)
final slice1 = dataset[[5]];  // shape: [50, 20]

// Range slice
final slice2 = dataset[[Slice(0, 10)]];  // shape: [10, 50, 20]

// Mixed slicing
final slice3 = dataset[[Slice(0, 10), 5, Slice(0, 5)]];  // shape: [10, 5]

// Negative indices work too
final slice4 = dataset[[Slice(-10, null)]];  // last 10 along first axis
```

## Attributes

```dart
final dataset = file.openDataset('/data');

// List attributes
print('Attributes: ${dataset.attr.keys}');

// Read attribute
final units = dataset.attr['units'];
final scale = dataset.attr['scale_factor'];

// Check existence
if (dataset.attr.containsKey('description')) {
  print(dataset.attr['description']);
}
```

Groups also have attributes:
```dart
final group = file.openGroup('/measurements/');
print(group.attr['creation_date']);
```

## Compression Info

```dart
final dataset = file.openDataset('/compressed_data');

// Check if chunked
if (dataset.layout == H5D_layout_t.CHUNKED) {
  print('Chunk size: ${dataset.getChunkSize()}');

  final filter = dataset.getFilter();
  print('Filter: ${filter.filterType}');
  print('Compression ratio: ${filter.compressionRatio}');
}
```

## Zero-Copy Design

The library uses zero-copy transfer between HDF5 and NumD:

```dart
// Reading: HDF5 writes directly into NumD's memory
final data = dataset.getData();  // No intermediate copy

// Writing: NumD's memory is read directly by HDF5
dataset.setData(data);  // No intermediate copy
```

This means large datasets don't need double the memory during transfer.

## Platform Support

- macOS (arm64 + x86_64)
- iOS (arm64)

Requires the HDF5 C library.

## Building

The native library is in `hdf5_c_libs`. Build scripts are provided for each platform.

## License

MIT
