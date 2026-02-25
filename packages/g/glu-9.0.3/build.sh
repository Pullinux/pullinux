#!/bin/bash

mkdir -p build
cd       build

meson setup --prefix=$XORG_PREFIX                       \
            --buildtype=release                         \
            -D default_library=shared                   \
            $(pkgconf opengl || echo -D gl_provider=gl) \
            ..
            
ninja
DESTDIR=$PCKDIR ninja install
