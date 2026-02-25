#!/bin/bash

sed -i '/^udev/,$ s/^/#/' util/meson.build

mkdir -p build
cd       build

meson setup --prefix=/usr ..   \
            --buildtype=release
            

ninja
DESTDIR=$PCKDIR ninja install

chmod u+s $PCKDIR/usr/bin/fusermount3
