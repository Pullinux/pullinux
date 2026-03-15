#!/bin/bash

patch -Np1 -i ../efivar-39-upstream_fixes-1.patch

make ENABLE_DOCS=0
make DESTDIR=$PCKDIR install ENABLE_DOCS=0 LIBDIR=/usr/lib
