#!/bin/bash

mkdir -p build
cd       build

meson setup --prefix=/usr         \
            --buildtype=release   \
            -D tests=false        \
            -D udev=true          \
            -D valgrind=disabled  \
            .. 

ninja
DESTDIR=$PCKDIR ninja install

#32 bit

rm -rf *

CC="gcc -m32" CXX="g++ -m32"         \
PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
meson setup --prefix=/usr            \
            --buildtype=release      \
            --libdir=/usr/lib32      \
            -D tests=false           \
            -D udev=true             \
            -D valgrind=disabled     \
            ..
            
ninja

mkdir -p $PCKDIR/usr/lib32

DESTDIR=$PWD/DESTDIR ninja install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
