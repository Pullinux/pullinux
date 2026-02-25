#!/bin/bash

make -f makefile

mkdir -p $PCKDIR/usr/bin

install -v -m755 unrar $PCKDIR/usr/bin
