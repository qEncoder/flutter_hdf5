#include "hdf5_deconstruct.h"
#include "iostream"


extern "C" void custom_H5G_close(long int *groupID){
    std::cout << "closing the following group :: " << *groupID;
    hid_t test = *groupID;
    herr_t error = H5Gclose(test);
    std::cout << " \t exit code ::  " << error << std::endl;
    free(groupID);
}

void custom_H5D_close(long int *dsID){
    std::cout << "closing the following dataset :: " << *dsID;
    hid_t test = *dsID;
    herr_t error = H5Dclose(test);
    std::cout << " \t exit code ::  " << error << std::endl;
    free(dsID);
}