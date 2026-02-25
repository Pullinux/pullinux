#!/bin/bash

make prefix=/usr
make prefix=/usr DESTDIR=$PCKDIR install

rm -v $PCKDIR/usr/lib/libzstd.a

#32 bit

make clean
CC="gcc -m32" make prefix=/usr

mkdir -p $PCKDIR/usr/lib32
mkdir -p $PCKDIR/usr/lib32/pkgconfig

make prefix=/usr DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib/* $PCKDIR/usr/lib32/
sed -e "/^libdir/s/lib$/lib32/" -i $PCKDIR/usr/lib32/pkgconfig/libzstd.pc
