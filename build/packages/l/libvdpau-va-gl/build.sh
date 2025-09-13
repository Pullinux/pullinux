
mkdir build &&
cd    build &&

cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=$XORG_PREFIX -D CMAKE_POLICY_VERSION_MINIMUM=3.5 ..

make

make DESTDIR=$PCKDIR install


#32bit
mkdir -p $PCKDIR/usr/lib32
rm -rf * 
CC="gcc -m32" CXX="g++ -m32"              \
PKG_CONFIG_PATH=/usr/lib32/pkgconfig      \
cmake -D CMAKE_BUILD_TYPE=Release         \
      -D CMAKE_INSTALL_PREFIX=/usr        \
      -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -W no-dev .. 

make
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib/* $PCKDIR/usr/lib32
rm -rf DESTDIR
ldconfig
