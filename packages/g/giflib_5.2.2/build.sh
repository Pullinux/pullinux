#!/bin/bash

patch -Np1 -i ../giflib-5.2.2-upstream_fixes-1.patch
patch -Np1 -i ../giflib-5.2.2-security_fixes-1.patch
cp pic/gifgrid.gif doc/giflib-logo.gif

make
make DESTDIR=$PCKDIR PREFIX=/usr install

rm -fv $PCKDIR/usr/lib/libgif.a 
