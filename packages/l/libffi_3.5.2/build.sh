#!/bin/bash

./configure --prefix=/usr    \
            --disable-static \
            --with-gcc-arch=x86-64

make
make DESTDIR=$PCKDIR install


#32 bit

make distclean
CC="gcc -m32" CXX="g++ -m32"         \
./configure --prefix=/usr            \
            --libdir=/usr/lib32      \
            --host=i686-pc-linux-gnu \
            --disable-static         \
            --with-gcc-arch=i686

make
mkdir -p $PCKDIR/usr/lib32
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
