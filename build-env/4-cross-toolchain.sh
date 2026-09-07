set -e

cd ${LFS:?}/sources

tar -xf binutils-2.47.tar.xz
cd binutils-2.47

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

mkdir -v build
cd       build

../configure                     \
    --target=$LFS_TGT            \
    --prefix=$LFS/tools          \
    --with-glibc-version=2.44    \
    --with-sysroot=$LFS          \
    --with-newlib                \
    --without-headers            \
    --enable-default-pie         \
    --enable-default-ssp         \
    --disable-fixincludes        \
    --enable-initfini-array      \
    --disable-nls                \
    --disable-shared             \
    --enable-multilib            \
    --with-multilib-list=m64,m32 \
    --disable-decimal-float      \
    --disable-threads            \
    --disable-libatomic          \
    --disable-libgomp            \
    --disable-libquadmath        \
    --disable-libssp             \
    --disable-libvtv             \
    --disable-libstdcxx          \
    --enable-languages=c,c++

make
make install

cat ../gcc/{limitx,glimits,limity}.h  > \
  $($LFS_TGT-gcc -print-file-name=include)/limits.h

cd ..

cd ${LFS:?}/sources

rm -rf gcc-16.2.0

tar -xf linux-7.1.8.tar.xz

cd linux-7.1.8

make mrproper

make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr

cd ${LFS:?}/sources

rm -rf linux-7.1.8

tar -xf glibc-2.44.tar.xz

cd glibc-2.44

ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3

patch -Np1 -i ../glibc-fhs-1.patch

patch -Np1 -i ../glibc-2.44-upstream_fixes-1.patch

mkdir -v build
cd       build

echo "rootsbindir=/usr/sbin" > configparms

echo "config1" >> ${LFS:?}/sources/stat.txt

../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib           \
      --enable-kernel=5.10
    
echo "make1" >> ${LFS:?}/sources/stat.txt
make
echo "inst1" >> ${LFS:?}/sources/stat.txt
make DESTDIR=$LFS install

echo "sed" >> ${LFS:?}/sources/stat.txt
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

echo "clean" >> ${LFS:?}/sources/stat.txt
make clean
find .. -name "*.a" -delete

echo "config2" >> ${LFS:?}/sources/stat.txt
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
      --enable-kernel=5.10

echo "make2" >> ${LFS:?}/sources/stat.txt
make

echo "inst2" >> ${LFS:?}/sources/stat.txt
make DESTDIR=$PWD/DESTDIR install

echo "finish2" >> ${LFS:?}/sources/stat.txt
cp -a DESTDIR/usr/lib32 $LFS/usr/
install -vm644 DESTDIR/usr/include/gnu/{lib-names,stubs}-32.h \
               $LFS/usr/include/gnu/


echo "ln2" >> ${LFS:?}/sources/stat.txt
ln -svf ../lib32/ld-linux.so.2 $LFS/lib/ld-linux.so.2

echo "done" >> ${LFS:?}/sources/stat.txt
cd ${LFS:?}/sources

rm -rf glibc-2.44

tar -xf gcc-16.2.0.tar.xz
cd gcc-16.2.0

mkdir -v build
cd       build

../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --build=$(../config.guess)      \
    CXX=$LFS_TGT-gcc           \
    --prefix=/usr                   \
    --enable-multilib               \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/16.2.0

make

make DESTDIR=$LFS install

rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la

