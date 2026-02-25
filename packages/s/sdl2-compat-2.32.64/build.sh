#!/bin/bash

mkdir -p build
cd       build

cmake -D CMAKE_INSTALL_PREFIX=/usr   \
      -D CMAKE_BUILD_TYPE=Release    \
      -D CMAKE_SKIP_INSTALL_RPATH=ON \
      -D SDL2COMPAT_STATIC=OFF       \
      -D SDL2COMPAT_TESTS=OFF        \
      -W no-dev -G Ninja .. 

ninja
DESTDIR=$PCKDIR ninja install

rm -vf $PCKDIR/usr/lib/libSDL2_test.a
