#!/bin/bash

mkdir build &&
cd    build &&

cmake -D CMAKE_INSTALL_PREFIX=$QT6DIR \
      -D CMAKE_BUILD_TYPE=Release     \
      -D BUILD_WITH_QT6=ON            \
      -D BUILD_TESTING=OFF            \
      -W no-dev ..  

make
make DESTDIR=$PCKDIR install
