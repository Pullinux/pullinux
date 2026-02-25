#!/bin/bash

patch -Np1 -i ../xine-lib-1.2.13-upstream_fixes-1.patch

patch -Np1 -i ../xine-lib-1.2.13-gcc15_fixes-1.patch

patch -Np1 -i ../xine-lib-1.2.13-ffmpeg8.patch

./configure --prefix=/usr          \
            --disable-vcd          \
            --disable-w32dll       \
            --with-external-dvdnav \
            --docdir=/usr/share/doc/xine-lib-1.2.13

make
make DESTDIR=$PCKDIR install
