# hdf5

### HDF5 library for Flutter with zero-copy support.

### What Was Fixed
##### The Memory Bug: Double-close error in lib/src/c_to_dart_calls/dataset.dart

Root Cause: Line 270 was manually closing spaceId, then line 271 called
spaceInfo.dispose() which tried to close the same spaceId again, causing
HDF5 error "not a dataspace"

Fix Applied:
1. Removed the manual HDF5lib.H5S.close(spaceId) call in the writeData()
   function
2. Let spaceInfo.dispose() handle the cleanup properly
3. Added h5file.close() to print_dataset_info() to prevent resource leak