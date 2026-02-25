
cd ${LFS:?}/sources

wget https://ftpmirror.gnu.org/findutils/findutils-4.10.0.tar.xz

tar -xf findutils-4.10.0.tar.xz

cd findutils-4.10.0

./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)

make findutils-4.10.0

make DESTDIR=$LFS install

cd ${LFS:?}/sources

rm -rf 

wget https://ftpmirror.gnu.org/gawk/gawk-5.3.2.tar.xz

tar -xf gawk-5.3.2.tar.xz

cd gawk-5.3.2

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install


cd ${LFS:?}/sources

rm -rf gawk-5.3.2

wget https://ftpmirror.gnu.org/grep/grep-3.12.tar.xz

tar -xf grep-3.12.tar.xz

cd grep-3.12

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make

make DESTDIR=$LFS install


cd ${LFS:?}/sources

rm -rf grep-3.12

wget https://ftpmirror.gnu.org/gzip/gzip-1.14.tar.xz

tar -xf gzip-1.14.tar.xz

cd gzip-1.14

./configure --prefix=/usr --host=$LFS_TGT

make

make DESTDIR=$LFS install



cd ${LFS:?}/sources

rm -rf gzip-1.14

wget https://ftpmirror.gnu.org/make/make-4.4.1.tar.gz

tar -xf make-4.4.1.tar.gz

cd make-4.4.1

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install


cd ${LFS:?}/sources

rm -rf make-4.4.1

wget https://ftpmirror.gnu.org/patch/patch-2.8.tar.xz

tar -xf patch-2.8.tar.xz

cd patch-2.8

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install

cd ${LFS:?}/sources

rm -rf patch-2.8

