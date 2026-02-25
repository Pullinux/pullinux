#!/bin/bash

sed 's/! $output_file eq/$output_file ne/' -i tp/Texinfo/Convert/*.pm

./configure --prefix=/usr

make
make DESTDIR=$PCKDIR install
