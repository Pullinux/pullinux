#!/bin/bash

./configure --prefix=/usr

make
make DESTDIR=$PCKDIR install
make install

ln -svfn aspell-0.60 $PCKDIR/usr/lib/aspell

mkdir -p $PCKDIR/usr/bin

install -v -m 755 scripts/ispell $PCKDIR/usr/bin/
install -v -m 755 scripts/spell $PCKDIR/usr/bin/

tar xf ../aspell6-en-2020.12.07-0.tar.bz2 
cd aspell6-en-2020.12.07-0                

./configure 
make
make DESTDIR=$PCKDIR install
