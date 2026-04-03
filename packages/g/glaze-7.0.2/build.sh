#!/bin/bash

mkdir -p build
cd       build

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D glaze_BUILD_EXAMPLES=OFF  \
      -D glaze_DEVELOPER_MODE=OFF  \
      -D glaze_ENABLE_FUZZING=OFF  \
      -G Ninja ..

ninja
DESTDIR=$PCKDIR ninja install
