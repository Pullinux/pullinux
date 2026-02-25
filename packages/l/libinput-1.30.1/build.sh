#!/bin/bash

mkdir -p build
cd       build

meson setup --prefix=/usr             \
            --buildtype=release       \
            -D debug-gui=false        \
            -D tests=false            \
            -D libwacom=false         \
            .. 

ninja
DESTDIR=$PCKDIR ninja install
