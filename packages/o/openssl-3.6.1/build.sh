#!/bin/bash

./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic

make

sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl DESTDIR=$PCKDIR install


#32 bit

make distclean
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib32        \
         shared                \
         zlib-dynamic          \
         linux-x86

make
mkdir -p $PCKDIR/usr/lib32
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
