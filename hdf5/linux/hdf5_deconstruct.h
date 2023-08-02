#include "hdf5.h"

extern "C" void custom_H5G_close(long int *groupID);
extern "C" void custom_H5D_close(long int *datasetID); 