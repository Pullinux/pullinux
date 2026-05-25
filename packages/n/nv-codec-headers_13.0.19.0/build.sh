#!/bin/bash

make DESTDIR=$PCKDIR PREFIX=/usr install

mkdir -p $PCKDIR/usr/lib32/pkgconfig/

ln -sfv /usr/lib/pkgconfig/ffnvcodec.pc $PCKDIR/usr/lib32/pkgconfig/ffnvcodec.pc
