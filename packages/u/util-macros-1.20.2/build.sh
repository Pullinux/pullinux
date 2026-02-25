#!/bin/bash

echo "XORG PREFIX: $XORG_PREFIX"
echo "XORG CONFIG: $XORG_CONFIG"

./configure $XORG_CONFIG

make DESTDIR=$PCKDIR install
