#!/bin/bash

pushd squashfs-tools

sed "s/#XZ_SUPPORT/XZ_SUPPORT/" -i Makefile

make
mkdir -p $PCKDIR/usr/bin

make INSTALL_DIR=$PCKDIR/usr/bin install
