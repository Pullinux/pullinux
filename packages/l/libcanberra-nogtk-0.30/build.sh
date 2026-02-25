#!/bin/bash

patch -Np1 -i ../libcanberra-0.30-wayland-1.patch

./configure --prefix=/usr --disable-oss --disable-gtk3

make
make docdir=/usr/share/doc/libcanberra-0.30 DESTDIR=$PCKDIR install
