#!/bin/bash

# Copy files from here into an install...

CHRENV=${1:?}

if [ ! -d "$CHRENV" ]; then
    echo "Must supply a valid path for chroot environment"
    exit 1
fi

echo "Copying package data..."

cp -r ../../packages $CHRENV/usr/share/pullinux/

echo "Copying scripts..."

cp -r plx-build $CHRENV/usr/bin/
cp -r plx-install $CHRENV/usr/bin/
