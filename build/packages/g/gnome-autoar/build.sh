mkdir __build && cd __build
meson setup --prefix=/usr       \
            --buildtype=release \
            -D vapi=true        \
            -D tests=true       \
            ..
ninja
DESTDIR=$PCKDIR ninja install
