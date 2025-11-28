sed -e 's/GROUP="render"/GROUP="video"/' \
    -e 's/GROUP="sgx", //'               \
    -i rules.d/50-udev-default.rules.in

mkdir -p build
cd       build

meson setup ..                \
      --prefix=/usr           \
      --buildtype=release     \
      -D default-dnssec=no    \
      -D firstboot=false      \
      -D install-tests=false  \
      -D ldconfig=false       \
      -D sysusers=false       \
      -D rpmmacrosdir=no      \
      -D homed=disabled       \
      -D userdb=false         \
      -D man=disabled         \
      -D mode=release         \
      -D pamconfdir=no        \
      -D dev-kvm-mode=0660    \
      -D nobody-group=nogroup \
      -D sysupdate=disabled   \
      -D ukify=disabled       \
      -D docdir=/usr/share/doc/systemd-257.8

ninja 
DESTDIR=$PCKDIR ninja install

mkdir -p $PCKDIR/usr/share/man

tar -xf $PCKBASE/files/systemd-man-pages-257.8.tar.xz \
    --no-same-owner --strip-components=1   \
    -C $PCKDIR/usr/share/man


#32bit
mkdir -p $PCKDIR/usr/lib32
mkdir -p $PCKDIR/usr/lib32/pkgconfig/

rm -rf *

PKG_CONFIG_PATH="/usr/lib32/pkgconfig" \
CC="gcc -m32"                        \
CXX="g++ -m32"                       \
LANG=en_US.UTF-8                     \
meson setup ..                       \
      --prefix=/usr                  \
      --libdir=/usr/lib32            \
      --buildtype=release            \
      -D default-dnssec=no           \
      -D firstboot=false             \
      -D install-tests=false         \
      -D ldconfig=false              \
      -D sysusers=false              \
      -D rpmmacrosdir=no             \
      -D homed=disabled              \
      -D userdb=false                \
      -D man=disabled                \
      -D mode=release 


LANG=en_US.UTF-8 ninja
LANG=en_US.UTF-8 DESTDIR=$PWD/DESTDIR ninja install
cp -av DESTDIR/usr/lib32/libsystemd.so* $PCKDIR/usr/lib32/
cp -av DESTDIR/usr/lib32/libudev.so* $PCKDIR/usr/lib32/
cp -v  DESTDIR/usr/lib32/pkgconfig/* $PCKDIR/usr/lib32/pkgconfig/

rm -rf DESTDIR
