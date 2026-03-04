#!/bin/bash

patch -Np1 -i ../polkit-gnome-0.105-consolidated_fixes-1.patch

./configure --prefix=/usr

make
make DESTDIR=$PCKDIR install

mkdir -p $PCKDIR/etc/xdg/autostart &&
cat > $PCKDIR/etc/xdg/autostart/polkit-gnome-authentication-agent-1.desktop << "EOF"
[Desktop Entry]
Name=PolicyKit Authentication Agent
Comment=PolicyKit Authentication Agent
Exec=/usr/libexec/polkit-gnome-authentication-agent-1
Terminal=false
Type=Application
Categories=
NoDisplay=true
OnlyShowIn=GNOME;XFCE;Unity;
AutostartCondition=GNOME3 unless-session gnome
EOF


