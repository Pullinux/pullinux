
cd ${LFS:?}/sources

wget https://ftpmirror.gnu.org/sed/sed-4.9.tar.xz

tar -xf sed-4.9.tar.xz

cd sed-4.9

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make

make DESTDIR=$LFS install

cd ${LFS:?}/sources
rm -rf sed-4.9

wget https://ftpmirror.gnu.org/tar/tar-1.35.tar.xz

tar -xf tar-1.35.tar.xz
cd tar-1.35

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install


cd ${LFS:?}/sources
rm -rf tar-1.35

wget https://github.com//tukaani-project/xz/releases/download/v5.8.2/xz-5.8.2.tar.xz
tar -xf xz-5.8.2.tar.xz
cd xz-5.8.2

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.8.2

make

make DESTDIR=$LFS install

rm -v $LFS/usr/lib/liblzma.la

cd ${LFS:?}/sources
rm -rf xz-5.8.2

tar -xf binutils-2.46.0.tar.xz
cd binutils-2.46.0

sed '6031s/$add_dir//' -i ltmain.sh

mkdir -v build
cd       build
../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --enable-gprofng=no        \
    --disable-werror           \
    --enable-64-bit-bfd        \
    --enable-new-dtags         \
    --enable-default-hash-style=gnu

make
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}

cd ${LFS:?}/sources
rm -rf binutils-2.46.0

tar -xf gcc-15.2.0.tar.xz
cd gcc-15.2.0

tar -xf ../mpfr-4.2.2.tar.xz
mv -v mpfr-4.2.2 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc

sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64

sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' \
      -i gcc/config/i386/i386.h

sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

mkdir -v build
cd       build

mlist=m64,m32
../configure                    \
    --build=$(../config.guess)  \
    --host=$LFS_TGT             \
    --target=$LFS_TGT           \
    --prefix=/usr               \
    --with-build-sysroot=$LFS   \
    --enable-default-pie        \
    --enable-default-ssp        \
    --disable-nls               \
    --enable-multilib           \
    --with-multilib-list=$mlist \
    --disable-libatomic         \
    --disable-libgomp           \
    --disable-libquadmath       \
    --disable-libsanitizer      \
    --disable-libssp            \
    --disable-libvtv            \
    --enable-languages=c,c++    \
    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc

make

make DESTDIR=$LFS install

ln -sv gcc $LFS/usr/bin/cc

cd ${LFS:?}/sources
rm -rf gcc-15.2.0
