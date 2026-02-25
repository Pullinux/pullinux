#!/bin/bash

cargo vendor
patch -Np1 -i ../glycin-2.0.8-xorg_prefix-1.patch

patch -Np1 -i ../glycin-2.0.8-xbm_xpm-1.patch
cargo vendor

mkdir -p build
cd       build

meson setup --prefix=/usr           \
            --buildtype=release     \
            -D libglycin-gtk4=false \
            -D tests=false ..

ninja
DESTDIR=$PCKDIR ninja install
