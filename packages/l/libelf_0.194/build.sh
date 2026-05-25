#!/bin/bash

./configure --prefix=/usr        \
            --disable-debuginfod \
            --enable-libdebuginfod=dummy

make -C lib
make -C libelf

make -C libelf DESTDIR=$PCKDIR install
mkdir -p $PCKDIR/usr/lib/pkgconfig

install -vm644 config/libelf.pc $PCKDIR/usr/lib/pkgconfig
rm $PCKDIR/usr/lib/libelf.a


#32 bit

make distclean
CC="gcc -m32" CXX="g++ -m32"         \
./configure --prefix=/usr            \
            --libdir=/usr/lib32      \
            --host=i686-pc-linux-gnu \
            --disable-debuginfod     \
            --enable-libdebuginfod=dummy

make -C lib
make -C libelf

mkdir -p $PCKDIR/usr/lib32

make DESTDIR=$PWD/DESTDIR -C libelf install
install -vDm644 config/libelf.pc DESTDIR/usr/lib32/pkgconfig/libelf.pc
rm -vf DESTDIR/usr/lib32/libelf.a
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32

