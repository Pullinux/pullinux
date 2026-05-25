#!/bin/bash

mkdir -p build
cd       build

meson setup ..                  \
      --prefix=/usr             \
      --buildtype=release       \
      -D documentation=disabled \
      -D tests=disabled 
            

ninja
DESTDIR=$PCKDIR ninja install
