mkdir __build && cd __build
meson setup --prefix=/usr       \
            --buildtype=release \
            -D examples=false   \
            -D gtk_doc=false    \
            ..        
ninja
DESTDIR=$PCKDIR ninja install
