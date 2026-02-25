#!/bin/bash

mkdir -p build
cd       build

meson setup --prefix=/usr --buildtype=release -D update-mimedb=true .. 

ninja
DESTDIR=$PCKDIR ninja install
