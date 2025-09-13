sed -i -e 's/GROUP="render"/GROUP="video"/' \
       -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in

mkdir __build && cd __build

meson setup ..                 \
      --prefix=/usr            \
      --buildtype=release      \
      -D default-dnssec=no     \
      -D firstboot=false       \
      -D install-tests=false   \
      -D ldconfig=false        \
      -D man=auto              \
      -D sysusers=false        \
      -D rpmmacrosdir=no       \
      -D homed=disabled        \
      -D userdb=false          \
      -D mode=release          \
      -D pam=enabled           \
      -D pamconfdir=/etc/pam.d \
      -D dev-kvm-mode=0660     \
      -D nobody-group=nogroup  \
      -D sysupdate=disabled    \
      -D ukify=disabled        \
      -D docdir=/usr/share/doc/systemd-257.8

ninja
DESTDIR=$PCKDIR ninja install

#32bit
mkdir -p $PCKDIR/usr/lib32/pkgconfig
rm -rf *
LANG=en_US.UTF-8                     \
meson setup --cross-file lib32       \
            --prefix=/usr            \
            --libdir=/usr/lib32      \
            --buildtype=release      \
            -D default-dnssec=no     \
            -D firstboot=false       \
            -D install-tests=false   \
            -D ldconfig=false        \
            -D man=disabled          \
            -D sysusers=false        \
            -D rpmmacrosdir=no       \
            -D homed=disabled        \
            -D userdb=false          \
            -D mode=release          \
            -D pam=enabled           \
            -D pamconfdir=/etc/pam.d \
            .. 


LANG=en_US.UTF-8 ninja

LANG=en_US.UTF-8 DESTDIR=$PWD/DESTDIR ninja install          &&
cp -vR DESTDIR/usr/lib32/security       $PCKDIR/usr/lib32           &&
cp -va DESTDIR/usr/lib32/libsystemd.so* $PCKDIR/usr/lib32           &&
cp -va DESTDIR/usr/lib32/libudev.so*    $PCKDIR/usr/lib32           &&
cp -v  DESTDIR/usr/lib32/pkgconfig/*    $PCKDIR/usr/lib32/pkgconfig &&
rm -rf DESTDIR
