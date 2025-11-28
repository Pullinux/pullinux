
PATH+=:/usr/sbin                \
./configure --prefix=/usr       \
            --enable-cmdlib     \
            --enable-pkgconfig  \
            --enable-udev_sync

make

make DESTDIR=$PCKDIR install
make DESTDIR=$PCKDIR install_systemd_units

sed -e '/locking_dir =/{s/#//;s/var/run/}' \
    -i $PCKDIR/etc/lvm/lvm.conf
