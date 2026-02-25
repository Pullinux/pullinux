#!/bin/bash

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xapian-core-1.4.30

make
make DESTDIR=$PCKDIR install
