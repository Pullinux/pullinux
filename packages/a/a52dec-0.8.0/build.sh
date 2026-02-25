#!/bin/bash

./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --enable-shared         \
            --disable-static        \
            CFLAGS="${CFLAGS:--g -O3} -fPIC"

make
make DESTDIR=$PCKDIR install

mkdir -p $PCKDIR/usr/include/a52dec

cp liba52/a52_internal.h $PCKDIR/usr/include/a52dec
