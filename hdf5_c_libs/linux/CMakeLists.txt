# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "hdf5_c_libs")
project(${PROJECT_NAME} LANGUAGES CXX)

set(hdf5_c_libs_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/lib/hdf5.so"
  PARENT_SCOPE
)
