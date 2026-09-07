
cd ${LFS:?}/sources

tar -xf findutils-4.11.0.tar.xz

cd findutils-4.11.0

./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)

make findutils-4.11.0

make DESTDIR=$LFS install

cd ${LFS:?}/sources

rm -rf 

tar -xf gawk-5.4.1.tar.xz

cd gawk-5.4.1

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install


cd ${LFS:?}/sources

rm -rf gawk-5.4.1

tar -xf grep-3.12.tar.xz

cd grep-3.12

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make

make DESTDIR=$LFS install


cd ${LFS:?}/sources

rm -rf grep-3.12

tar -xf gzip-1.14.tar.xz

cd gzip-1.14

./configure --prefix=/usr --host=$LFS_TGT

make

make DESTDIR=$LFS install



cd ${LFS:?}/sources

rm -rf gzip-1.14

tar -xf make-4.4.1.tar.gz

cd make-4.4.1

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install

cd ${LFS:?}/sources

rm -rf make-4.4.1

tar -xf patch-2.8.tar.xz

cd patch-2.8

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install

cd ${LFS:?}/sources

rm -rf patch-2.8
