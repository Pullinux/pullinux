#!/bin/bash

FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr

make
make DESTDIR=$PCKDIR install

make -C doc DESTDIR=$PCKDIR install-html docdir=/usr/share/doc/tar-1.35
