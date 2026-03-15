#!/bin/bash

./configure --prefix=/usr --with-x=no

make
make DESTDIR=$PCKDIR install
