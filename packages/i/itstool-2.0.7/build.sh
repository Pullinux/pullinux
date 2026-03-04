#!/bin/bash

patch -Np1 -i ../itstool-2.0.7-lxml-1.patch

PYTHON=/usr/bin/python3 ./autogen.sh --prefix=/usr 

make
make DESTDIR=$PCKDIR install
