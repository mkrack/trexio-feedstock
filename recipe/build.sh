#!/bin/bash
set -ex

# Set MPI compilers for parallel builds
if [[ "${mpi}" != "nompi" ]]; then
  export CC=mpicc
  export FC=mpifort
fi

# Build shared library libtrexio with HDF5 support
cmake -B build -S . ${CMAKE_ARGS} -GNinja -DENABLE_HDF5="ON"
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build

# Run tests if no cross-compilation was performed
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || -n "${CROSSCOMPILING_EMULATOR}" ]]; then
  ctest --test-dir build --output-on-failure -j${CPU_COUNT}
fi
