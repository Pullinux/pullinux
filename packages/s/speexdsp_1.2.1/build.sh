#!/bin/bash

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/speexdsp-1.2.1

make
make DESTDIR=$PCKDIR install


#32 bit

make distclean
CC="gcc -m32" CXX="g++ -m32"                     \
PKG_CONFIG=/usr/bin/i686-pc-linux-gnu-pkg-config \
./configure --prefix=/usr                        \
            --libdir=/usr/lib32                  \
            --host=i686-pc-linux-gnu             \
            --disable-static 

make
mkdir -p $PCKDIR/usr/lib32
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
