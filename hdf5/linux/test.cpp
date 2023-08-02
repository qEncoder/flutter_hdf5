#include "hdf5.h"

#include <iostream>


void custom_H5D_close(long int *dsID){
    std::cout << "closing the following dataset :: " << *dsID;
    hid_t test = *dsID;
    herr_t error = H5Dclose(test);
    std::cout << " \t exit code ::  " << error << std::endl;
    free(dsID);
}

int main(int argc, char const *argv[])
{
        
    int ret_val;
    hid_t file, dset, dset2;

    unsigned mode        = H5F_ACC_RDONLY;
    char     file_name[] = "test.hdf5";
    // assume a priori knowledge of dataset name and size
    char dset_name[] = "/Phase_shift";
    int  elts[10];

    file = H5Fopen(file_name, mode, H5P_DEFAULT);
    
    dset = H5Dopen2(file, dset_name, H5P_DEFAULT);

    dset2 = H5Dopen2(file, dset_name, H5P_DEFAULT);

    long int test = dset;
    long int* test_prt;
    test_prt = (long int*)malloc(sizeof(long int));
    test_prt[0] = test;

    // do something w/ the dataset elements
    std :: cout << "file :: " << file << " dset  ::" << dset  <<  " dset  ::" << dset2 << std:: endl;
    // int err = H5Dclose(test);
    custom_H5D_close(test_prt);
    // custom_H5D_close(test_prt);
    // err = H5Dclose(dset);
    // std :: cout << "err :: " << err <<std:: endl;

    H5Fclose(file);

    return 0;
}