#!/bin/bash

mkdir -p build
cd       build

meson setup --prefix=/usr ..

ninja
DESTDIR=$PCKDIR ninja install
