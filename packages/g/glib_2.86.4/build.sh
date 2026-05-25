#!/bin/bash

patch -Np1 -i ../glib-skip_warnings-1.patch

mkdir -p build
cd       build

meson setup ..                  \
      --prefix=/usr             \
      --buildtype=release       \
      -D introspection=disabled \
      -D glib_debug=disabled    \
      -D man-pages=disabled     \
      -D tests=false            \
      -D sysprof=disabled
            

ninja
DESTDIR=$PCKDIR ninja install

ninja install

tar xf ../../gobject-introspection-1.86.0.tar.xz &&

meson setup gobject-introspection-1.86.0 gi-build \
            --prefix=/usr --buildtype=release     &&
ninja -C gi-build

DESTDIR=$PCKDIR ninja -C gi-build install
ninja -C gi-build install

meson configure -D introspection=enabled &&
ninja
DESTDIR=$PCKDIR ninja install

#32 bit

rm -rf *

meson setup ..                  \
      --cross-file=lib32        \
      --prefix=/usr             \
      --libdir=/usr/lib32       \
      --buildtype=release       \
      -D introspection=disabled \
      -D glib_debug=disabled    \
      -D man-pages=disabled     \
      -D tests=false            \
      -D sysprof=disabled

ninja

mkdir -p $PCKDIR/usr/lib32

DESTDIR=$PWD/DESTDIR ninja install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
