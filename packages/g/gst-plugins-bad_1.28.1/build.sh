#!/bin/bash

mkdir -p build
cd       build

meson setup ..            \
      --prefix=/usr       \
      --buildtype=release \
      -D gpl=enabled 

ninja
DESTDIR=$PCKDIR ninja install
