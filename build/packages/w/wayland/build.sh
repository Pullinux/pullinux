mkdir __build && cd __build
meson setup ..            \
      --prefix=/usr       \
      --buildtype=release \
      -D documentation=false
ninja
DESTDIR=$PCKDIR ninja install

#32bit
mkdir -p $PCKDIR/usr/lib32
rm -rf * &&
CC="gcc -m32" CXX="g++ -m32"         \
PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
meson setup ..                       \
      --prefix=/usr                  \
      --libdir=/usr/lib32            \
      --buildtype=release            \
      -D documentation=false

ninja
DESTDIR=$PWD/DESTDIR ninja install 
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
ldconfig
