#!/bin/bash

./configure --prefix=/usr     \
            --disable-static  \
            --enable-lib-only \
            --docdir=/usr/share/doc/nghttp2-1.68.0

make
make DESTDIR=$PCKDIR install
