mkdir build
cd    build

meson setup --prefix=/usr --buildtype=release --wrap-mode=nofallback ..
ninja
DESTDIR=$PCKDIR ninja install

mkdir -p $PCKDIR/var/lib/dbus
ln -sfv /etc/machine-id $PCKDIR/var/lib/dbus

#32bit
mkdir -p $PCKDIR/usr/lib32
rm -rf *

PKG_CONFIG_PATH="/usr/lib32/pkgconfig" \
CC="gcc -m32 -march=i686"              \
CXX="g++ -m32 -march=i686"             \
meson setup --prefix=/usr --libdir=/usr/lib32 --buildtype=release --wrap-mode=nofallback ..
ninja
DESTDIR=$(pwd)/destdir ninja install
mkdir -pv $PCKDIR/usr/lib32/pkgconfig
cp -av $(pwd)/destdir/usr/lib32/libdbus-1.so* $PCKDIR/usr/lib32/
cp -av $(pwd)/destdir/usr/lib32/dbus-1.0 $PCKDIR/usr/lib32/
cp -v  $(pwd)/destdir/usr/lib32/pkgconfig/dbus-1.pc $PCKDIR/usr/lib32/pkgconfig/
