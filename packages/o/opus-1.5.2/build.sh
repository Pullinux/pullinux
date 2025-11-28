mkdir __build && cd __build
meson setup --prefix=/usr        \
            --buildtype=release  \
            -D docdir=/usr/share/doc/opus-1.5.2 
ninja
DESTDIR=$PCKDIR ninja install

#32bit
mkdir -p $PCKDIR/usr/lib32
rm -rf * &&
CC="gcc -m32" CXX="g++ -m32"         \
PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
meson setup --prefix=/usr            \
            --libdir=/usr/lib32      \
            --buildtype=release


ninja
DESTDIR=$PWD/DESTDIR ninja install 
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
ldconfig
