#!/bin/bash

./configure $XORG_CONFIG 

make
make DESTDIR=$PCKDIR install


#32 bit

make distclean
CC="gcc -m32" CXX="g++ -m32" PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
./configure $XORG_CONFIG --libdir=/usr/lib32 

make
mkdir -p $PCKDIR/usr/lib32
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
