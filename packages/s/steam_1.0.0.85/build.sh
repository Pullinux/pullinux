#!/bin/bash

ln -sf /usr/bin/true steamdeps

make DESTDIR=$PCKDIR install
mv -v $PCKDIR/usr/share/doc/steam{,-1.0.0.85}
