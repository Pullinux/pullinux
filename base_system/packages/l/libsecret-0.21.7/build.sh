mkdir bld &&
cd    bld &&

meson setup --prefix=/usr       \
            --buildtype=release \
            -D gtk_doc=false    \
            ..         
ninja
DESTDIR=$PCKDIR ninja install
