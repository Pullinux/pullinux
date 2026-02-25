#!/bin/bash

sed '/tools/d' -i Makefile.am &&
./autogen.sh

./configure --prefix=/usr         \
            --disable-sherlock265 \
            --disable-static 

make
make DESTDIR=$PCKDIR install
