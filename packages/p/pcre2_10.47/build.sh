#!/bin/bash

./configure --prefix=/usr                       \
            --docdir=/usr/share/doc/pcre2-10.47 \
            --enable-unicode                    \
            --enable-jit                        \
            --enable-pcre2-16                   \
            --enable-pcre2-32                   \
            --enable-pcre2grep-libz             \
            --enable-pcre2grep-libbz2           \
            --enable-pcre2test-libreadline      \
            --disable-static

make
make DESTDIR=$PCKDIR install


#32 bit

make distclean
CC="gcc -m32" CXX="g++ -m32"               \
./configure --prefix=/usr                  \
            --libdir=/usr/lib32            \
            --host=i686-pc-linux-gnu       \
            --enable-unicode               \
            --enable-jit                   \
            --enable-pcre2-16              \
            --enable-pcre2-32              \
            --enable-pcre2grep-libz        \
            --enable-pcre2grep-libbz2      \
            --enable-pcre2test-libreadline \
            --disable-static

make
mkdir -p $PCKDIR/usr/lib32
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
