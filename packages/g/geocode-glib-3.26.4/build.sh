mkdir __build && cd __build
meson setup --prefix=/usr           \
            --buildtype=release     \
            -D enable-gtk-doc=false \
            -D soup2=false          \
            ..    
ninja
DESTDIR=$PCKDIR ninja install
