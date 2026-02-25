#!/bin/bash

sed -i -r 's:"(/system):"/org/gnome\1:g' schemas/*.in

mkdir -p build
cd       build

meson setup --prefix=/usr ..   \
            --buildtype=release
            

ninja
DESTDIR=$PCKDIR ninja install
