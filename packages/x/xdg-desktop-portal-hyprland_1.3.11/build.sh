#!/bin/bash

rm -rf subprojects    

mkdir -p build
cd       build

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D SYSTEMD_SERVICES=ON       \
      -G Ninja ..      

ninja
DESTDIR=$PCKDIR ninja install
