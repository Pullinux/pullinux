
cd ${LFS:?}/sources

wget https://ftpmirror.gnu.org/m4/m4-1.4.21.tar.xz

tar -xf m4-1.4.21.tar.xz

cd m4-1.4.21

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install


cd ${LFS:?}/sources

rm -rf m4-1.4.21

wget https://invisible-mirror.net/archives/ncurses/ncurses-6.6.tar.gz

tar -xf ncurses-6.6.tar.gz

cd ncurses-6.6

mkdir build
pushd build
  ../configure --prefix=$LFS/tools AWK=gawk
  make -C include
  make -C progs tic
  install progs/tic $LFS/tools/bin
popd

./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            AWK=gawk

make
make DESTDIR=$LFS install
ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i $LFS/usr/include/curses.h

make distclean

CC="$LFS_TGT-gcc -m32"                \
CXX="$LFS_TGT-g++ -m32"               \
./configure --prefix=/usr             \
            --host=$LFS_TGT32         \
            --build=$(./config.guess) \
            --libdir=/usr/lib32       \
            --mandir=/usr/share/man   \
            --with-shared             \
            --without-normal          \
            --with-cxx-shared         \
            --without-debug           \
            --without-ada             \
            --disable-stripping

make

make DESTDIR=$PWD/DESTDIR TIC_PATH=$(pwd)/build/progs/tic install
ln -sv libncursesw.so DESTDIR/usr/lib32/libncurses.so
cp -Rv DESTDIR/usr/lib32/* $LFS/usr/lib32
rm -rf DESTDIR

cd ${LFS:?}/sources

rm -rf ncurses-6.6

wget https://ftpmirror.gnu.org/bash/bash-5.3.tar.gz
tar -xf bash-5.3.tar.gz
cd bash-5.3

./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc

make

make DESTDIR=$LFS install

ln -sv bash $LFS/bin/sh

cd ${LFS:?}/sources

rm -rf bash-5.3

wget https://ftpmirror.gnu.org/coreutils/coreutils-9.10.tar.xz
tar -xf coreutils-9.10.tar.xz
cd coreutils-9.10

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

make

make DESTDIR=$LFS install

mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8

cd ${LFS:?}/sources

rm -rf coreutils-9.10

wget https://ftpmirror.gnu.org/diffutils/diffutils-3.12.tar.xz
tar -xf diffutils-3.12.tar.xz
cd diffutils-3.12

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            gl_cv_func_strcasecmp_works=y \
            --build=$(./build-aux/config.guess)

make

make DESTDIR=$LFS install

cd ${LFS:?}/sources

rm -rf diffutils-3.12

wget https://astron.com/pub/file/file-5.46.tar.gz
tar -xf file-5.46.tar.gz
cd file-5.46

mkdir build
pushd build
  ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
  make
popd

./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)

make FILE_COMPILE=$(pwd)/build/src/file

make DESTDIR=$LFS install

rm -v $LFS/usr/lib/libmagic.la

cd ${LFS:?}/sources

rm -rf file-5.46

