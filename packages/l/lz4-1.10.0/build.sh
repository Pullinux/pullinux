#!/bin/bash

make BUILD_STATIC=no PREFIX=/usr
make BUILD_STATIC=no PREFIX=/usr DESTDIR=$PCKDIR install

#32 bit

make clean
CC="gcc -m32" make BUILD_STATIC=no

mkdir -p $PCKDIR/usr/lib32

make BUILD_STATIC=no   \
     PREFIX=/usr       \
     LIBDIR=/usr/lib32 \
     DESTDIR=$(pwd)/m32 install

cp -a m32/usr/lib32/* $PCKDIR/usr/lib32/
