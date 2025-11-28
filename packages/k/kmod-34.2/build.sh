mkdir -p build
cd       build

meson setup --prefix=/usr ..    \
            --buildtype=release \
            -D manpages=false

ninja
DESTDIR=$PCKDIR ninja install

#32bit
mkdir -p $PCKDIR/usr/lib32
cd .. &&
rm -rf build &&
mkdir build &&
cd build

PKG_CONFIG_PATH="/usr/lib32/pkgconfig" \
CC="gcc -m32 -march=i686"              \
CXX="g++ -m32 -march=i686"             \
meson setup --prefix=/usr ..    \
            --buildtype=release \
            --libdir=/usr/lib32 \
            -D manpages=false

ninja
DESTDIR=$PWD/DESTDIR ninja install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
