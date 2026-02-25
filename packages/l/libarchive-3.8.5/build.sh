#!/bin/bash

./configure --prefix=/usr --disable-static

make
make DESTDIR=$PCKDIR install

mkdir -p $PCKDIR/usr/bin

ln -sfv bsdunzip $PCKDIR/usr/bin/unzip
