#!/bin/bash

sed -i "/get_option/s/libdvdread/&-7.0.1/" meson.build

mkdir -p build
cd       build

meson setup --prefix=/usr ..   \
            --buildtype=release
            

ninja
DESTDIR=$PCKDIR ninja install
rm -fv $PCKDIR/usr/lib/libdvdread.a
