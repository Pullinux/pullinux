#!/bin/bash

mkdir build &&
cd    build &&

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D BUILD_TESTING=OFF         \
      -D WITH_ICON_GENERATION=OFF  \
      -W no-dev .. 

make
make DESTDIR=$PCKDIR install
