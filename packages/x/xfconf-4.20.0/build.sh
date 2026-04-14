#!/bin/bash

./configure --prefix=/usr --enable-wayland

make
make DESTDIR=$PCKDIR install
