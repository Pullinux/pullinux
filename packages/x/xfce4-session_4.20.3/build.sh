#!/bin/bash

./configure --prefix=/usr       \
            --sysconfdir=/etc   \
            --disable-legacy-sm  --enable-wayland

make
make DESTDIR=$PCKDIR install
