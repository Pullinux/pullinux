#!/bin/bash

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/libsamplerate-0.2.2

make
make DESTDIR=$PCKDIR install
