bash -e

touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

cd /sources
tar -xf gettext-1.0.tar.xz
cd gettext-1.0

./configure --disable-shared

make

cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

cd /sources
rm -rf gettext-1.0

tar -xf bison-3.8.2.tar.xz
cd bison-3.8.2

./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2

make

make install

cd /sources
rm -rf bison-3.8.2

tar -xf perl-5.42.0.tar.xz
cd perl-5.42.0

sh Configure -des                                         \
             -D prefix=/usr                               \
             -D vendorprefix=/usr                         \
             -D useshrplib                                \
             -D privlib=/usr/lib/perl5/5.42/core_perl     \
             -D archlib=/usr/lib/perl5/5.42/core_perl     \
             -D sitelib=/usr/lib/perl5/5.42/site_perl     \
             -D sitearch=/usr/lib/perl5/5.42/site_perl    \
             -D vendorlib=/usr/lib/perl5/5.42/vendor_perl \
             -D vendorarch=/usr/lib/perl5/5.42/vendor_perl

make 
make install

cd /sources
rm -rf perl-5.42.0

tar -xf Python-3.14.3.tar.xz
cd Python-3.14.3

./configure --prefix=/usr       \
            --enable-shared     \
            --without-ensurepip \
            --without-static-libpython

make 
make install

cd /sources
rm -rf Python-3.14.3

tar -xf texinfo-7.2.tar.xz
cd texinfo-7.2

./configure --prefix=/usr

make

make install

cd /sources
rm -rf texinfo-7.2

tar -xf util-linux-2.41.3.tar.xz
cd util-linux-2.41.3

mkdir -pv /var/lib/hwclock

./configure --libdir=/usr/lib     \
            --runstatedir=/run    \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-static      \
            --disable-liblastlog2 \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.41.3

make

make install
make distclean
CC="gcc -m32"                        \
./configure --host=i686-pc-linux-gnu \
            --libdir=/usr/lib32      \
            --runstatedir=/run       \
            --disable-chfn-chsh      \
            --disable-login          \
            --disable-nologin        \
            --disable-su             \
            --disable-setpriv        \
            --disable-runuser        \
            --disable-pylibmount     \
            --disable-static         \
            --disable-liblastlog2    \
            --without-python         \
            ADJTIME_PATH=/var/lib/hwclock/adjtime
make

make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR

cd /sources
rm -rf util-linux-2.41.3

rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
find /usr/lib32 -name \*.la -delete
rm -rf /tools

