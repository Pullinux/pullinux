mkdir __build && cd __build
meson setup --prefix=/usr            \
            --buildtype=release      \
            -D bash_completion=false \
            .. 
ninja
DESTDIR=$PCKDIR ninja install
