#!/bin/bash

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-1.0

make
make DESTDIR=$PCKDIR install
chmod -v 0755 $PCKDIR/usr/lib/preloadable_libintl.so
