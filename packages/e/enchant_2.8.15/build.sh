#!/bin/bash

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-static  \
            --docdir=/usr/share/doc/enchant-2.8.15

make
make DESTDIR=$PCKDIR install
