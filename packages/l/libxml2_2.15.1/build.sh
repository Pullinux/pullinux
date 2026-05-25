#!/bin/bash

sed -i "/'git'/,+3d" meson.build

mkdir -p build
cd       build

meson setup --prefix=/usr       \
            --buildtype=release \
            -D history=enabled  \
            -D icu=enabled
            

ninja
DESTDIR=$PCKDIR ninja install

sed 's/--static/--shared/' -i $PCKDIR/usr/bin/xml2-config

#32 bit

rm -rf *

CC="gcc -m32" CXX="g++ -m32"         \
PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
meson setup --prefix=/usr            \
            --libdir=/usr/lib32      \
            --buildtype=release      \
            -D history=enabled       \
            -D icu=enabled

ninja

mkdir -p $PCKDIR/usr/lib32

DESTDIR=$PWD/DESTDIR ninja install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
