patch -Np1 -i $PCKBASE/files/localsearch-3.9.0-libxml2_2_14-1.patch

mkdir __build && cd __build
meson setup --prefix=/usr       \
            --buildtype=release \
            -D man=false -D landlock=disabled       \
            ..  
ninja
DESTDIR=$PCKDIR ninja install
