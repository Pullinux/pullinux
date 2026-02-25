#!/bin/bash

mv -v tests/test_gdbus.py{,.nouse}         &&
mv -v tests/test_overrides_gtk.py{,.nouse}

mkdir -p build
cd       build

meson setup --prefix=/usr ..   \
            --buildtype=release
            

ninja
DESTDIR=$PCKDIR ninja install
