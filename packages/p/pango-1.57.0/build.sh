#!/bin/bash

mkdir -p build
cd       build

meson setup --prefix=/usr            \
            --buildtype=release      \
            --wrap-mode=nofallback   \
            -D introspection=enabled \
            ..    

ninja
DESTDIR=$PCKDIR ninja install
