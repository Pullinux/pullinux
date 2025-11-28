mkdir __build && cd __build
cmake -D CMAKE_INSTALL_PREFIX=/usr   \
      -D CMAKE_BUILD_TYPE=Release    \
      -D CMAKE_SKIP_INSTALL_RPATH=ON \
      -G Ninja .. 
ninja
DESTDIR=$PCKDIR ninja install

#32bit
mkdir -p $PCKDIR/usr/lib32
rm -rf ./*

ASFLAGS+=" --32" CFLAGS+=" -m32"       \
CXXFLAGS+=" -m32"                      \
PKG_CONFIG_PATH=/usr/lib32/pkgconfig   \
cmake -D CMAKE_INSTALL_PREFIX=/usr     \
        -D CMAKE_INSTALL_LIBDIR=lib32    \
        -D CMAKE_BUILD_TYPE=Release      \
        -D CMAKE_SKIP_INSTALL_RPATH=ON   \
        -G Ninja ..
        
ninja
DESTDIR=$PWD/DESTDIR ninja install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
ldconfig
