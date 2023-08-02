cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "hdf5")
project(${PROJECT_NAME} LANGUAGES C CXX)

set(hdf5_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/lib/libhdf5.so"
  PARENT_SCOPE
)


# find_package(HDF5 REQUIRED COMPONENTS C HL)

# add_library(hdf5_deconstruct SHARED
#   "hdf5_deconstruct.cpp"
# )
# set_target_properties(hdf5_deconstruct PROPERTIES
#   LINKER_LANGUAGE CXX
#   PUBLIC_HEADER hdf5_deconstruct.h
#   OUTPUT_NAME "hdf5_deconstruct"
# )
# target_link_libraries(hdf5_deconstruct PRIVATE HDF5::HDF5)
# target_compile_definitions(hdf5_deconstruct PUBLIC DART_SHARED_LIB)

# add_executable(test test.cpp)
# target_link_libraries(test PRIVATE HDF5::HDF5)
