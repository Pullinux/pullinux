mkdir __build && cd __build
meson setup --prefix=/usr       \
            --buildtype=release \
            -D gtk4=true        \
            -D vapi=true        \
            -D docs=false       \
            -D man=false        \
            ..      
ninja
DESTDIR=$PCKDIR ninja install
