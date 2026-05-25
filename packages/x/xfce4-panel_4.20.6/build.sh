#!/bin/bash

./configure --prefix=/usr --sysconfdir=/etc --enable-wayland

make
make DESTDIR=$PCKDIR install
