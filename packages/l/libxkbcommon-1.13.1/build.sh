#!/bin/bash

mkdir -p build
cd       build

meson setup ..             \
      --prefix=/usr        \
      --buildtype=release  \
      -D enable-docs=false

ninja
DESTDIR=$PCKDIR ninja install
