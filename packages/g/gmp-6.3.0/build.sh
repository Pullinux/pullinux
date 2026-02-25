#!/bin/bash

sed -i '/long long t1;/,+1s/()/(...)/' configure

./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0

make
make html
make DESTDIR=$PCKDIR install
make DESTDIR=$PCKDIR install-html


#32 bit

make distclean
cp -v configfsf.guess config.guess
cp -v configfsf.sub   config.sub

ABI="32"                               \
CFLAGS="-m32 -O2 -pedantic -fomit-frame-pointer -mtune=generic -march=i686" \
CXXFLAGS="$CFLAGS"                     \
PKG_CONFIG_PATH="/usr/lib32/pkgconfig" \
./configure --prefix=/usr              \
            --host=i686-pc-linux-gnu   \
            --disable-static           \
            --enable-cxx               \
            --libdir=/usr/lib32        \
            --includedir=/usr/include/m32/gmp

sed -i 's/$(exec_prefix)\/include/$\(includedir\)/' Makefile

make
mkdir -p $PCKDIR/usr/lib32
mkdir -p $PCKDIR/usr/include/m32/

make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
cp -Rv DESTDIR/usr/include/m32/* $PCKDIR/usr/include/m32/
