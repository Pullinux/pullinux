#!/bin/bash

./configure $XORG_CONFIG

make DESTDIR=$PCKDIR install
