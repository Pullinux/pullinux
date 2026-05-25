#!/bin/bash

mkdir -p build
cd       build

meson setup             \
   --prefix=/usr        \
   --buildtype=release  \
   -D libproxy=disabled \
   .. 

ninja
DESTDIR=$PCKDIR ninja install
