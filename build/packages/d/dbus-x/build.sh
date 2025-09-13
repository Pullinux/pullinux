
mkdir  build &&
cd     build &&

meson setup --prefix=/usr          \
            --buildtype=release    \
            --wrap-mode=nofallback \
            .. 

ninja

DESTDIR=$PCKDIR ninja install

