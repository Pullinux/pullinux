#!/bin/bash

./configure --prefix=/usr               \
            --disable-static            \
            --with-default-dict=/usr/lib/cracklib/pw_dict 

make
make DESTDIR=$PCKDIR install
