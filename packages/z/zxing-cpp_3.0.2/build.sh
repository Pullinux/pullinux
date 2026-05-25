#!/bin/bash

mkdir build &&
cd    build &&

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D ZXING_C_API=OFF           \
      -D ZXING_EXAMPLES=OFF        \
      -D ZXING_WRITERS=BOTH        \
      -W no-dev .. 

make
make DESTDIR=$PCKDIR install
