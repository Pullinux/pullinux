mkdir build &&
cd    build &&

meson setup --prefix=/usr --buildtype=release ..

ninja
DESTDIR=$PCKDIR ninja install


#32bit
mkdir -p $PCKDIR/usr/lib32
rm -rf * &&
meson setup --prefix=/usr       \
            --libdir=/usr/lib32 \
            --cross-file=lib32  \
            --buildtype=release \
            ..
ninja
DESTDIR=$PWD/DESTDIR ninja install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
ldconfig
