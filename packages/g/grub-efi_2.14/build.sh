#!/bin/bash

./configure --prefix=/usr        \
            --sysconfdir=/etc    \
            --disable-efiemu     \
            --with-platform=efi  \
            --target=x86_64      \
            --disable-werror

make
make DESTDIR=$PCKDIR -C grub-core install
