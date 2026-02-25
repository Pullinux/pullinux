set -e

cd ${LFS:?}/sources

wget https://sourceware.org/pub/binutils/releases/binutils-2.46.0.tar.xz

tar -xf binutils-2.46.0.tar.xz
cd binutils-2.46.0

mkdir -v build
cd       build

../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-new-dtags  \
             --enable-default-hash-style=gnu

make
make install

cd ${LFS:?}/sources
rm -rf binutils-2.46.0

wget https://ftpmirror.gnu.org/gcc/gcc-15.2.0/gcc-15.2.0.tar.xz

wget https://ftpmirror.gnu.org/mpfr/mpfr-4.2.2.tar.xz

wget https://ftpmirror.gnu.org/mpc/mpc-1.3.1.tar.gz

wget https://ftpmirror.gnu.org/gmp/gmp-6.3.0.tar.xz

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

mkdir -v build
cd       build

mlist=m64,m32
../configure                    \
    --target=$LFS_TGT           \
    --prefix=$LFS/tools         \
    --with-glibc-version=2.43   \
    --with-sysroot=$LFS         \
    --with-newlib               \
    --without-headers           \
    --enable-default-pie        \
    --enable-default-ssp        \
    --enable-initfini-array     \
    --disable-nls               \
    --disable-shared            \
    --enable-multilib           \
    --with-multilib-list=$mlist \
    --disable-decimal-float     \
    --disable-threads           \
    --disable-libatomic         \
    --disable-libgomp           \
    --disable-libquadmath       \
    --disable-libssp            \
    --disable-libvtv            \
    --disable-libstdcxx         \
    --enable-languages=c,c++

make
make install

cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h


cd ${LFS:?}/sources

rm -rf gcc-15.2.0

wget https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.18.10.tar.xz

tar -xf linux-6.18.10.tar.xz

cd linux-6.18.10

make mrproper

make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr

cd ${LFS:?}/sources

rm -rf linux-6.18.10

wget https://ftpmirror.gnu.org/glibc/glibc-2.43.tar.xz
wget https://www.linuxfromscratch.org/patches/lfs/development/glibc-fhs-1.patch

tar -xf glibc-2.43.tar.xz

cd glibc-2.43

ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3

patch -Np1 -i ../glibc-fhs-1.patch

mkdir -v build
cd       build

echo "rootsbindir=/usr/sbin" > configparms

../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib           \
      --enable-kernel=5.4
    
make
make DESTDIR=$LFS install

sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

make clean
find .. -name "*.a" -delete

CC="$LFS_TGT-gcc -m32"                   \
CXX="$LFS_TGT-g++ -m32"                  \
../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT32                  \
      --build=$(../scripts/config.guess) \
      --disable-nscd                     \
      --with-headers=$LFS/usr/include    \
      --libdir=/usr/lib32                \
      --libexecdir=/usr/lib32            \
      libc_cv_slibdir=/usr/lib32         \
      --enable-kernel=5.4

make

make DESTDIR=$PWD/DESTDIR install
cp -a DESTDIR/usr/lib32 $LFS/usr/
install -vm644 DESTDIR/usr/include/gnu/{lib-names,stubs}-32.h \
               $LFS/usr/include/gnu/
ln -svf ../lib32/ld-linux.so.2 $LFS/lib/ld-linux.so.2

cd ${LFS:?}/sources

rm -rf glibc-2.43

tar -xf gcc-15.2.0.tar.xz
cd gcc-15.2.0

mkdir -v build
cd       build

../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --enable-multilib               \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/15.2.0

make

make DESTDIR=$LFS install

rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la

