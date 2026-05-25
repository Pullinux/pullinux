#!/bin/bash

sed -i 's/-Os/-O2/' Makefile.sharedlibrary &&
make -f Makefile.sharedlibrary INSTALL_PREFIX=/usr

make -f Makefile.sharedlibrary DESTDIR=$PCKDIR INSTALL_PREFIX=/usr install
