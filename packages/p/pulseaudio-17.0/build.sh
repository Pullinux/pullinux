#!/bin/bash

mkdir -p build
cd       build

meson setup --prefix=/usr       \
            --buildtype=release \
            -D database=gdbm    \
            -D doxygen=false    \
            -D bluez5=disabled  \
            -D tests=false      \
            ..
            

ninja
DESTDIR=$PCKDIR ninja install

rm $PCKDIR/usr/share/dbus-1/system.d/pulseaudio-system.conf

#32 bit

rm -rf *

meson setup --cross-file=lib32  \
            --prefix=/usr       \
            --libdir=/usr/lib32 \
            --buildtype=release \
            -D database=gdbm    \
            -D doxygen=false    \
            -D bluez5=disabled  \
            -D tests=false      \
            ..

ninja

mkdir -p $PCKDIR/usr/lib32

DESTDIR=$PWD/DESTDIR ninja install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
