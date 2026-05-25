#!/bin/bash

sed '/ORIGIN/d' -i lib/CMakeLists.txt

mkdir build &&
cd    build 

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      ..                           

sed -i '/GZIP/s/:.*$/=/' CMakeCache.txt

make
make DESTDIR=$PCKDIR install
