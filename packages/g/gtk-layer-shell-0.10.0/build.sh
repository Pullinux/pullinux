#!/bin/bash

mkdir -p build
cd       build

meson --prefix=/usr \
          --wrap-mode=nofallback \
          --buildtype=plain \
          -Dtests=false \
          -Ddocs=false \
          -Dintrospection=true \
          ..
        
ninja
DESTDIR=$PCKDIR ninja install
