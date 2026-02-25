#!/bin/bash

sed -i '/v0/{n;s/new:/new:kb=^?:/}' termcap 
printf '\tkbs=\\177,\n' >> terminfo 

TERMINFO=/usr/share/terminfo \
./configure $XORG_CONFIG     \
            --with-app-defaults=/etc/X11/app-defaults

make
make DESTDIR=$PCKDIR install

mkdir -pv $PCKDIR/usr/share/applications 
cp -v *.desktop $PCKDIR/usr/share/applications/

mkdir -p $PCKDIR/etc/X11/app-defaults/

cat >> $PCKDIR/etc/X11/app-defaults/XTerm << "EOF"
*VT100*locale: true
*VT100*faceName: Monospace
*VT100*faceSize: 10
*backarrowKeyIsErase: true
*ptyInitialErase: true
EOF
