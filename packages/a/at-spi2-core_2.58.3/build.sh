#!/bin/bash

mkdir -p build
cd       build

meson setup ..                  \
      --prefix=/usr             \
      --buildtype=release       \
      -D gtk2_atk_adaptor=false

ninja
DESTDIR=$PCKDIR ninja install
