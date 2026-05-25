#!/bin/bash

mkdir build &&
cd    build &&

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D MOD_SOX=OFF               \
      -D MOD_MOVIT=OFF             \
      -D MOD_VIDSTAB=OFF           \
      -D MOD_JACKRACK=OFF          \
      -D MOD_RUBBERBAND=OFF        \
      -W no-dev ..

make
make DESTDIR=$PCKDIR install
