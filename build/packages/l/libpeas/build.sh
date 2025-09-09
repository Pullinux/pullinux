mkdir __build && cd __build
meson setup --prefix=/usr          \
            --buildtype=release    \
            --wrap-mode=nofallback \
            -D python3=false       \
            ..  
ninja
DESTDIR=$PCKDIR ninja install
