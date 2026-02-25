#!/bin/bash

sed -i 's#/local##' libxdo.pc

make WITHOUT_RPATH_FIX=1

make PREFIX=/usr INSTALLMAN=/usr/share/man DESTDIR=$PCKDIR install
