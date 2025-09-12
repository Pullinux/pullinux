sed 's/apiversion/soup_version/' -i docs/reference/meson.build

mkdir __build && cd __build
meson setup --prefix=/usr          \
            --buildtype=release    \
            --wrap-mode=nofallback \
            ..  
ninja
DESTDIR=$PCKDIR ninja install
