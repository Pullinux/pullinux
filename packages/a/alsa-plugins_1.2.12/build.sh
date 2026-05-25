#!/bin/bash

./configure --sysconfdir=/etc --disable-libav

make
make DESTDIR=$PCKDIR install


#32 bit

make distclean
CC="gcc -m32" CXX="g++ -m32"    \
./configure --libdir=/usr/lib32 \
            --sysconfdir=/etc   \
            --disable-libav     \
            --host=i686-pc-linux-gnu 

make
mkdir -p $PCKDIR/usr/lib32
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
