#!/bin/bash

mkdir -p libtiff-build 
cd       libtiff-build 

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -W no-dev -G Ninja ..

ninja
DESTDIR=$PCKDIR ninja install
mv -v $PCKDIR/usr/share/doc/{tiff,libtiff-4.7.1}
