#!/bin/bash

patch -Np1 -i ../libsoup-3.6.6-upstream_fixes-1.patch

sed 's/apiversion/soup_version/' -i docs/reference/meson.build

mkdir -p build
cd       build

meson setup --prefix=/usr          \
            --buildtype=release    \
            --wrap-mode=nofallback \
            ..          

ninja
DESTDIR=$PCKDIR ninja install
