#!/bin/bash
patch -Np1 -i ../libvpx-1.16.0-security_fix-1.patch

sed -i 's/cp -p/cp/' build/make/Makefile 

mkdir libvpx-build            
cd    libvpx-build            

../configure --prefix=/usr    \
             --enable-shared  \
             --disable-static

make
make DESTDIR=$PCKDIR install
