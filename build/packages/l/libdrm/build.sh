mkdir __build && cd __build
meson setup --prefix=$XORG_PREFIX \
            --buildtype=release   \
            -D tests=false        \
            -D udev=true          \
            -D valgrind=disabled  \
            ..          
ninja
DESTDIR=$PCKDIR ninja install

#32bit
mkdir -p $PCKDIR/usr/lib32
rm -rf ./*
CC="gcc -m32" CXX="g++ -m32"         \
PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
meson setup --prefix=/usr            \
            --buildtype=release      \
            --libdir=/usr/lib32      \
            -D tests=false           \
            -D udev=true             \
            -D valgrind=disabled     \
            .. 

ninja
DESTDIR=$PWD/DESTDIR ninja install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
ldconfig
