set -e

cd ${LFS:?}/sources

tar -xf sed-4.10.tar.xz

cd sed-4.10

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make

make DESTDIR=$LFS install

cd ${LFS:?}/sources
rm -rf sed-4.10

tar -xf tar-1.35.tar.xz
cd tar-1.35

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install


cd ${LFS:?}/sources
rm -rf tar-1.35

tar -xf xz-5.8.3.tar.xz
cd xz-5.8.3

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.8.3

make

make DESTDIR=$LFS install

rm -v $LFS/usr/lib/liblzma.la

cd ${LFS:?}/sources
rm -rf xz-5.8.3

tar -xf binutils-2.47.tar.xz
cd binutils-2.47

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
rm -rf binutils-2.47

tar -xf gcc-16.2.0.tar.xz
cd gcc-16.2.0

tar -xf ../mpfr-4.2.2.tar.xz
mv -v mpfr-4.2.2 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.4.1.tar.xz
mv -v mpc-1.4.1 mpc

sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64

sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' \
      -i gcc/config/i386/i386.h

sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

mkdir -v build
cd       build

../configure                     \
    --build=$(../config.guess)   \
    --host=$LFS_TGT              \
    --target=$LFS_TGT            \
    --prefix=/usr                \
    --with-build-sysroot=$LFS    \
    --enable-default-pie         \
    --enable-default-ssp         \
    --disable-fixincludes        \
    --disable-nls                \
    --enable-multilib            \
    --with-multilib-list=m64,m32 \
    --disable-libatomic          \
    --disable-libgomp            \
    --disable-libquadmath        \
    --disable-libsanitizer       \
    --disable-libssp             \
    --disable-libvtv             \
    --enable-languages=c,c++     \
    CXX_FOR_TARGET="$LFS_TGT-gcc -nostdinc++" \
    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc \
    target_configargs=gcc_cv_target_thread_file=posix

make

make DESTDIR=$LFS install

ln -sv gcc $LFS/usr/bin/cc

cd ${LFS:?}/sources
rm -rf gcc-16.2.0
