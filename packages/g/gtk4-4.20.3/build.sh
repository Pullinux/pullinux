mkdir build &&
cd    build &&

meson setup --prefix=/usr            \
            --buildtype=release      \
            -D broadway-backend=true \
            -D introspection=enabled \
            -D vulkan=enabled        \
            .. 
ninja

DESTDIR=$PCKDIR ninja install
