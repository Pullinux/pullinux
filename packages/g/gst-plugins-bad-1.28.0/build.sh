#!/bin/bash

patch -Np1 -i ../gst-plugins-bad-1.28.0-zxing_cpp_3-1.patch

mkdir -p build
cd       build

meson setup ..            \
      --prefix=/usr       \
      --buildtype=release \
      -D gpl=enabled 

ninja
DESTDIR=$PCKDIR ninja install
