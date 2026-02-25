#!/bin/bash

sed -e "/OUTDIR/s|,| / 'librsvg-2.61.4', '--no-namespace-dir',|" \
    -e '/output/s|Rsvg-2.0|librsvg-2.61.4|'                      \
    -i doc/meson.build

mkdir -p build
cd       build

meson setup --prefix=/usr ..   \
            --buildtype=release
            

ninja
DESTDIR=$PCKDIR ninja install
