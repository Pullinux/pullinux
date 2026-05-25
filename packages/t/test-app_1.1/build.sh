#!/bin/bash

echo "Building and installing in $PCKDIR"

mkdir -p $PCKDIR/usr/bin

echo "echo 'hello test'" > $PCKDIR/usr/bin/test-app-1.1

mkdir -p $PCKDIR/usr/share/test-app/data/
mkdir -p $PCKDIR/usr/share/test-app/other/
mkdir -p $PCKDIR/opt/test/
mkdir -p $PCKDIR/opt/other-test/

echo "file1" > $PCKDIR/usr/share/test-app/data/file1

echo "file2" > $PCKDIR/usr/share/test-app/data/file2

echo "file3" > $PCKDIR/usr/share/test-app/other/file3

echo "file4" > $PCKDIR/usr/share/test-app/file4

echo "file5" > $PCKDIR/opt/test/frompck-file5

echo "file6" > $PCKDIR/opt/other-test/frompck-file6
