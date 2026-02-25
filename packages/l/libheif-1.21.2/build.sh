#!/bin/bash

patch -Np1 -i ../libheif-1.21.2-svt_av1_build_fix-1.patch

mkdir -p build
cd       build


cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D WITH_GDK_PIXBUF=OFF       \
      -D WITH_OpenH264_DECODER=OFF \
      -G Ninja ..  

ninja
DESTDIR=$PCKDIR ninja install
