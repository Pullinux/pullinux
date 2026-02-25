#!/bin/bash

sed 's/--image-base/--nonexist-linker-option/' -i configure

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-efiemu  \
            --disable-werror

make
make DESTDIR=$PCKDIR install
