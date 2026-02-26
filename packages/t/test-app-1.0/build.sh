#!/bin/bash

echo "Building and installing in $PCKDIR"

mkdir -p $PCKDIR/usr/bin

echo "echo 'hello test'" > $PCKDIR/usr/bin/test-app-1.0


