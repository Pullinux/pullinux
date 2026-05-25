#!/bin/bash

./configure --prefix=/usr

make
make DESTDIR=$PCKDIR install

rm -fv $PCKDIR/usr/lib/libltdl.a

#32 bit

make distclean
CC="gcc -m32" ./configure    \
    --host=i686-pc-linux-gnu \
    --prefix=/usr            \
    --libdir=/usr/lib32

make
mkdir -p $PCKDIR/usr/lib32
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
