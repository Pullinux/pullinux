#!/bin/bash

mkdir -p build
cd       build

meson setup ..               \
      --prefix=/usr          \
      --buildtype=release    \
      --wrap-mode=nodownload 

ninja
DESTDIR=$PCKDIR ninja install
