#!/bin/bash

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr

make

rm -f /usr/bin/gawk-5.3.2

make DESTDIR=$PCKDIR install

ln -sv gawk.1 $PCKDIR/usr/share/man/man1/awk.1
