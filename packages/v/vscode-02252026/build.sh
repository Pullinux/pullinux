#!/bin/bash

wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" -O a.tar.gz

tar -xf a.tar.gz

mkdir -p $PCKDIR/opt/

mv VSCode-linux-x64 $PCKDIR/opt/vs-code
