#!/bin/bash

sed -i '/( oxygen/ s/)/scalable )/' CMakeLists.txt

mkdir build &&
cd    build &&

cmake -D CMAKE_INSTALL_PREFIX=/usr -W no-dev ..
make DESTDIR=$PCKDIR install
