
patch -Np1 -i $PCKBASE/files/libgweather-4.4.4-upstream_fix-1.patch

mkdir __build && cd __build
meson setup --prefix=/usr       \
            --buildtype=release \
            -D gtk_doc=false    \
            ..  
ninja
DESTDIR=$PCKDIR ninja install
