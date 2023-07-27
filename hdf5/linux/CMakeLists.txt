cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "hdf5")
project(${PROJECT_NAME} LANGUAGES C)

set(hdf5_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/lib/libhdf5.so"
  PARENT_SCOPE
)
