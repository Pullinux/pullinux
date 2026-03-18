#!/bin/bash

git clone https://gitlab.freedesktop.org/wlroots/wlroots
cd wlroots
git checkout 0.19

mkdir -p build
cd       build

meson setup --prefix=/usr ..   \
            --buildtype=release -Dwerror=false
            

ninja
DESTDIR=$PCKDIR ninja install
