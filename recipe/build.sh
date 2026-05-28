#!/bin/bash
set -ex

declare -a EXTRA_CMAKE_ARGS

# Configure MPI variables without hijacking CC and FC
if [[ "${mpi}" != "nompi" ]]; then
  # Tell OpenMPI wrappers which underlying compilers to wrap if called
  export OMPI_CC="${CC}"
  export OMPI_FC="${FC}"
  # Force CMake to find the specific Conda MPI installation
  EXTRA_CMAKE_ARGS+=(
    -DMPI_C_COMPILER="${PREFIX}/bin/mpicc"
    -DMPI_Fortran_COMPILER="${PREFIX}/bin/mpifort"
  )
fi

# Build shared library libtrexio with HDF5 support
cmake -B build -S . \
  ${CMAKE_ARGS} \
  "${EXTRA_CMAKE_ARGS[@]}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER="${CC}" \
  -DCMAKE_Fortran_COMPILER="${FC}" \
  -DENABLE_HDF5="ON" \
  -GNinja

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build

# Run tests if no cross-compilation was performed
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  ctest --test-dir build --output-on-failure -j"${CPU_COUNT}"
fi
