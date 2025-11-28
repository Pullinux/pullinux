
mkdir -p $PCKDIR/etc
mkdir -p $PCKDIR/etc/ld.so.conf.d

patch -Np1 -i $PCKBASE/files/glibc-2.42-fhs-1.patch

sed -e '/unistd.h/i #include <string.h>' \
    -e '/libc_rwlock_init/c\
  __libc_rwlock_define_initialized (, reset_lock);\
  memcpy (&lock, &reset_lock, sizeof (lock));' \
    -i stdlib/abort.c 

mkdir build
cd build

echo "rootsbindir=/usr/sbin" > configparms

../configure --prefix=/usr                            \
             --disable-werror                         \
             --enable-kernel=5.4                      \
             --enable-stack-protector=strong          \
             --disable-nscd                           \
             libc_cv_slibdir=/usr/lib

make
touch $PCKDIR/etc/ld.so.conf

sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

make DESTDIR=$PCKDIR install

sed '/RTLDLIST=/s@/usr@@g' -i $PCKDIR/usr/bin/ldd

#32bit
rm -rf ./*
find .. -name "*.a" -delete

CC="gcc -m32" CXX="g++ -m32" \
../configure                             \
      --prefix=/usr                      \
      --host=i686-pc-linux-gnu           \
      --build=$(../scripts/config.guess) \
      --libdir=/usr/lib32                \
      --libexecdir=/usr/lib32            \
      --disable-werror                   \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib32         \
      --enable-stack-protector=strong    \
      --enable-kernel=5.4

make
make DESTDIR=$PWD/DESTDIR install

mkdir -p $PCKDIR/usr/lib32
mkdir -p $PCKDIR/usr/include/gnu/

cp -a DESTDIR/usr/lib32/* /usr/lib32/
install -vm644 DESTDIR/usr/include/gnu/{lib-names,stubs}-32.h \
               $PCKDIR/usr/include/gnu/
