#!/bin/bash

./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2

make
make DESTDIR=$PCKDIR install


#32 bit

make distclean
CC="gcc -m32" ./configure \
    --prefix=/usr         \
    --disable-static      \
    --sysconfdir=/etc     \
    --libdir=/usr/lib32   \
    --host=i686-pc-linux-gnu

make
mkdir -p $PCKDIR/usr/lib32
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
