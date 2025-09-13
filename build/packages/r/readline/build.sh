
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf

./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.3
make SHLIB_LIBS="-lncursesw"
make DESTDIR=$PCKDIR install

#32bit
mkdir -p $PCKDIR/usr/lib32
make distclean

CC="gcc -m32" ./configure \
    --host=i686-pc-linux-gnu      \
    --prefix=/usr                 \
    --libdir=/usr/lib32           \
    --disable-static              \
    --with-curses
make SHLIB_LIBS="-lncursesw"
make SHLIB_LIBS="-lncursesw" DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
