sed 's@/bin/sh@/bin/sh -l@' -i gnome-session/gnome-session.in

mkdir __build && cd __build
meson setup --prefix=/usr              \
            --buildtype=release        \
            -D man=false               \
            -D docbook=false           \
            ..     
ninja
DESTDIR=$PCKDIR ninja install

rm -v $PCKDIR/usr/share/xsessions/gnome.desktop || true
rm -v $PCKDIR/usr/share/wayland-sessions/gnome.desktop || true
