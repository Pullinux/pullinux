#!/bin/bash

sed -i '/install_man/,$d' meson.build 

mkdir -p build
cd       build

meson setup --prefix=/usr                  \
            --buildtype=release            \
            -D xkb_output_dir=/var/lib/xkb \
            -D secure-rpc=false            \
            .. 

ninja
DESTDIR=$PCKDIR ninja install
