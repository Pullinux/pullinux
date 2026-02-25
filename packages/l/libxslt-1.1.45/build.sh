#!/bin/bash

./configure --prefix=/usr    \
            --disable-static \
            --without-python \
            --docdir=/usr/share/doc/libxslt-1.1.45

make
make DESTDIR=$PCKDIR install
