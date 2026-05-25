#!/bin/bash

mkdir -p build
cd       build

meson setup --prefix=/usr             \
            --buildtype=release       \
            -D server=disabled        \
            -D libseat-seatd=disabled \
            .. 

ninja
DESTDIR=$PCKDIR ninja install
