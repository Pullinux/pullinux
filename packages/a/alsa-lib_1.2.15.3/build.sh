#!/bin/bash

./configure --prefix=/usr

make
make DESTDIR=$PCKDIR install

mkdir -p $PCKDIR/usr/share/alsa

tar -C $PCKDIR/usr/share/alsa --strip-components=1 -xf ../alsa-ucm-conf-1.2.15.3.tar.bz2

#32 bit

make distclean
CC="gcc -m32" CXX="g++ -m32"         \
./configure --libdir=/usr/lib32      \
            --host=i686-pc-linux-gnu

make
mkdir -p $PCKDIR/usr/lib32
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
