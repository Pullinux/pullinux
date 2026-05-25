#!/bin/bash

mkdir -p build
cd       build

meson setup --prefix=/usr --buildtype=release -D libdbus=auto .. 

ninja
DESTDIR=$PCKDIR ninja install
