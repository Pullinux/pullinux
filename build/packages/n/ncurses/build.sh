./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib/pkgconfig
make
make DESTDIR=$PCKDIR install

make DESTDIR=$PWD/dest install
mkdir -p $PCKDIR/usr/lib/pkgconfig

install -vm755 dest/usr/lib/libncursesw.so.6.5 $PCKDIR/usr/lib
rm -v  dest/usr/lib/libncursesw.so.6.5
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i dest/usr/include/curses.h
cp -av dest/* $PCKDIR/

for lib in ncurses form panel menu ; do
    ln -sfv lib${lib}w.so $PCKDIR/usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc    $PCKDIR/usr/lib/pkgconfig/${lib}.pc
done

ln -sfv libncursesw.so $PCKDIR/usr/lib/libcurses.so

#32bit
mkdir -p $PCKDIR/usr/lib32
make distclean

CC="gcc -m32" CXX="g++ -m32" \
./configure --prefix=/usr           \
            --host=i686-pc-linux-gnu \
            --libdir=/usr/lib32     \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib32/pkgconfig

make
make DESTDIR=$PWD/DESTDIR install

mkdir -p DESTDIR/usr/lib32/pkgconfig
for lib in ncurses form panel menu ; do
    rm -vf                    DESTDIR/usr/lib32/lib${lib}.so
    echo "INPUT(-l${lib}w)" > DESTDIR/usr/lib32/lib${lib}.so
    ln -svf ${lib}w.pc        DESTDIR/usr/lib32/pkgconfig/$lib.pc
done
rm -vf                     DESTDIR/usr/lib32/libcursesw.so
echo "INPUT(-lncursesw)" > DESTDIR/usr/lib32/libcursesw.so
ln -sfv libncurses.so      DESTDIR/usr/lib32/libcurses.so

cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
