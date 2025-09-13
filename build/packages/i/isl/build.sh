
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/isl-0.27

make

make DESTDIR=$PCKDIR install

mkdir -pv $PCKDIR/usr/share/gdb/auto-load/usr/lib
mv -v $PCKDIR/usr/lib/libisl*gdb.py $PCKDIR/usr/share/gdb/auto-load/usr/lib
