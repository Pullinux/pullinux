mkdir __build && cd __build
meson setup --prefix=/usr --buildtype=release ..
ninja
DESTDIR=$PCKDIR ninja install

rm -v $PCKDIR/etc/profile.d/vte.*
