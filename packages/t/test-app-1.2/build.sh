#!/bin/bash

echo "Building and installing in $PCKDIR"

mkdir -p $PCKDIR/usr/bin

echo "echo 'hello test'" > $PCKDIR/usr/bin/test-app-1.1

mkdir -p $PCKDIR/usr/share/test-app/data/
mkdir -p $PCKDIR/usr/share/test-app/other2/

echo "file1" > $PCKDIR/usr/share/test-app/data/file1

echo "file2" > $PCKDIR/usr/share/test-app/data/file5

echo "file3" > $PCKDIR/usr/share/test-app/other2/file6

echo "file4" > $PCKDIR/usr/share/test-app/file7

