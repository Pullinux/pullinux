#!/bin/bash

make
make NO_ARLIB=1 LIBDIR=/usr/lib BINDIR=/usr/bin SBINDIR=/usr/sbin DESTDIR=$PCKDIR install
