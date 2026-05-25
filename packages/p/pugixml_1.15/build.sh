#!/bin/bash

mkdir build 
cd    build 

cmake -D CMAKE_INSTALL_PREFIX=/usr   \
      -D CMAKE_BUILD_TYPE=Release    \
      -D CMAKE_SKIP_INSTALL_RPATH=ON \
      -D BUILD_SHARED_LIBS=ON        \
      -G Ninja .. 

ninja
DESTDIR=$PCKDIR ninja install
