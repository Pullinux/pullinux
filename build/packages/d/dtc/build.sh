mkdir __build && cd __build
meson setup --prefix=/usr         \
            --buildtype=release   \
            -D python=disabled ..
ninja
DESTDIR=$PCKDIR ninja install

rm $PCKDIR/usr/lib/libfdt.a
