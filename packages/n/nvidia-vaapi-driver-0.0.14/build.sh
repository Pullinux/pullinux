#!/bin/bash

mkdir -p build
cd       build

meson setup --prefix=/usr ..   \
            --buildtype=release
            

ninja
DESTDIR=$PCKDIR ninja install

#32 bit

rm -rf *

meson setup --prefix=/usr            \
            --buildtype=release      \
            --cross-file=lib32       \
            .. 

ninja

mkdir -p $PCKDIR/usr/lib32

DESTDIR=$PWD/DESTDIR ninja install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
