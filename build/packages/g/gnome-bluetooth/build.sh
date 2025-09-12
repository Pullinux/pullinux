patch -Np1 -i $PCKBASE/files/gnome-bluetooth-47.1-build_fix-1.patch

mkdir __build && cd __build
meson setup --prefix=/usr --buildtype=release ..
ninja
DESTDIR=$PCKDIR ninja install
