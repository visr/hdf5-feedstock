
#!/bin/bash

export LIBRARY_PATH="${PREFIX}/lib"

if [[ ! -z "$mpi" && "$mpi" != "nompi" ]]; then
  export CONFIGURE_ARGS="--enable-parallel ${CONFIGURE_ARGS}"
  export CC=mpicc
  export CXX=mpic++
  export FC=mpifort
else
  export CC=$(basename ${CC})
  export CXX=$(basename ${CXX})
  export F95=$(basename ${F95})
  export FC=$(basename ${FC})
fi

./configure --prefix="${PREFIX}" \
            ${CONFIGURE_ARGS} \
            --with-pic \
            --host="${HOST}" \
            --build="${BUILD}" \
            --enable-linux-lfs \
            --with-zlib="${PREFIX}" \
            --with-pthread=yes  \
            --enable-cxx \
            --enable-fortran \
            --enable-fortran2003 \
            --with-default-plugindir="${PREFIX}/lib/hdf5/plugin" \
            --enable-threadsafe \
            --enable-build-mode=production \
            --enable-unsupported \
            --enable-using-memchecker \
            --enable-clear-file-buffers \
            --with-ssl

# allow oversubscribing with openmpi in make check
export OMPI_MCA_rmaps_base_oversubscribe=yes

make -j "${CPU_COUNT}" ${VERBOSE_AT}
if [[ ! ${HOST} =~ .*powerpc64le.* ]]; then
  # https://github.com/h5py/h5py/issues/817
  # https://forum.hdfgroup.org/t/hdf5-1-10-long-double-conversions-tests-failed-in-ppc64le/4077
  make check RUNPARALLEL="${RECIPE_DIR}/mpiexec.sh -n 2"
fi
make install

rm -rf $PREFIX/share/hdf5_examples
