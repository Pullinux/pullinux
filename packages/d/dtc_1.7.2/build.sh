#!/bin/bash

patch -Np1 -i ../dtc-1.7.2-glibc_fixes-1.patch

mkdir -p build
cd       build

meson setup ..            \
      --prefix=/usr       \
      --buildtype=release \
      -D python=disabled 

ninja
DESTDIR=$PCKDIR ninja install

rm $PCKDIR/usr/lib/libfdt.a
