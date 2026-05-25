#!/bin/bash

./configure --prefix=/usr    \
            --disable-static \
            --disable-tests 

make
make DESTDIR=$PCKDIR install


#32 bit

make clean
CC="gcc -m32" CXX="g++ -m32"         \
PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
./configure --prefix=/usr            \
            --libdir=/usr/lib32      \
            --host=i686-pc-linux-gnu \
            --disable-static         \
            --disable-tests

make
mkdir -p $PCKDIR/usr/lib32
mkdir -p $PCKDIR/usr/include

make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
cp -v DESTDIR/usr/include/libunwind-x86.h $PCKDIR/usr/include
