#!/bin/bash

mkdir -p build
cd       build

meson setup ..              \
      --prefix=/usr         \
      --buildtype=release   \
      -D graphite2=disabled \
      -D tests=disabled
            

ninja
DESTDIR=$PCKDIR ninja install

#32 bit

rm -rf *

meson setup ..              \
      --cross-file=lib32    \
      --prefix=/usr         \
      --libdir=/usr/lib32   \
      --buildtype=release   \
      -D cairo=disabled     \
      -D graphite2=disabled \
      -D tests=disabled

ninja

mkdir -p $PCKDIR/usr/lib32

DESTDIR=$PWD/DESTDIR ninja install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
