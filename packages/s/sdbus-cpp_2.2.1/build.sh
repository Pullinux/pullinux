#!/bin/bash

mkdir -p build
cd       build

cmake -D CMAKE_INSTALL_PREFIX=/usr   \
      -D CMAKE_BUILD_TYPE=Release    \
      -D CMAKE_SKIP_INSTALL_RPATH=ON \
      -D CMAKE_INSTALL_DOCDIR=/usr/share/doc/sdbus-c++-2.2.1 \
      -G Ninja ..          

ninja
DESTDIR=$PCKDIR ninja install
