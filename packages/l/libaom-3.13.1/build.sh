#!/bin/bash

patch -Np1 -i ../libaom-3.13.1-nasm3-1.patch
sed -i 's/aom aom_static/aom/' build/cmake/aom_install.cmake

mkdir aom-build 
cd    aom-build 

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D BUILD_SHARED_LIBS=1       \
      -D ENABLE_DOCS=no            \
      -G Ninja .. 

ninja
DESTDIR=$PCKDIR ninja install
