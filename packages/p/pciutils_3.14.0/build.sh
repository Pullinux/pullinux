#!/bin/bash

sed -r '/INSTALL.*(PCI_IDS|update-pciids)/d' \
    -i Makefile

make PREFIX=/usr                \
     SHAREDIR=/usr/share/hwdata \
     SHARED=yes

make PREFIX=/usr                \
     SHAREDIR=/usr/share/hwdata \
     SHARED=yes   DESTDIR=$PCKDIR              \
     install install-lib        &&

chmod -v 755 $PCKDIR/usr/lib/libpci.so

