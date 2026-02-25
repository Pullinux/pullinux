#!/bin/bash

patch -Np1 -i ../vala-0.56.18-graphviz_13_fix-1.patch

./configure --prefix=/usr

make bootstrap
make DESTDIR=$PCKDIR install
