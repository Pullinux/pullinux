mkdir __build && cd __build
meson setup --prefix=/usr       \
            --buildtype=release \
            -D packagekit=false \
            ..     
ninja
DESTDIR=$PCKDIR ninja install


