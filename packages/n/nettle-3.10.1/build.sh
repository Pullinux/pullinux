#!/bin/bash

./configure --prefix=/usr --disable-static

make
make DESTDIR=$PCKDIR install

chmod -v 755 $PCKDIR/usr/lib/lib{hogweed,nettle}.so &&
install -vdm755 $PCKDIR/usr/share/doc/nettle-3.10.1 &&
install -vDm644 nettle.{html,pdf} -t $PCKDIR/usr/share/doc/nettle-3.10.1/
