patch -Np1 -i $PCKBASE/files/gjs-1.84.2-spidermonkey_140-1.patch

mkdir __build && cd __build
meson setup --prefix=/usr          \
            --buildtype=release    \
            --wrap-mode=nofallback \
            ..       
ninja
DESTDIR=$PCKDIR ninja install
