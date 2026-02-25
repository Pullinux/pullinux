#!/bin/bash

patch -Np1 -i ../cdparanoia-III-10.2-gcc_fixes-1.patch
patch -Np1 -i ../0001-Use-DESTDIR-in-install-Makefile-rule.patch

./configure --prefix=/usr --mandir=/usr/share/man 

make -j1

make DESTDIR=$PCKDIR install

chmod -v 755 $PCKDIR/usr/lib/libcdda_*.so.0.10.2 
rm -fv $PCKDIR/usr/lib/libcdda_*.a
