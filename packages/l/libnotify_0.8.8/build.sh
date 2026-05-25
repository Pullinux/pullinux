#!/bin/bash

mkdir -p build
cd       build

meson setup --prefix=/usr       \
            --buildtype=release \
            -D gtk_doc=false    \
            -D man=false        \
            ..      

ninja
DESTDIR=$PCKDIR ninja install
