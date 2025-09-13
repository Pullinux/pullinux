mkdir __build && cd __build
cmake -D CMAKE_INSTALL_PREFIX=/usr     \
      -D CMAKE_BUILD_TYPE=Release      \
      -D SPIRV_WERROR=OFF              \
      -D BUILD_SHARED_LIBS=ON          \
      -D SPIRV_TOOLS_BUILD_STATIC=OFF  \
      -D SPIRV-Headers_SOURCE_DIR=/usr \
      -G Ninja ..
ninja
DESTDIR=$PCKDIR ninja install

#32bit
mkdir -p $PCKDIR/usr/lib32
rm -rf ./*

CC="gcc -m32" CXX="g++ -m32"           \
PKG_CONFIG_PATH=/usr/lib32/pkgconfig   \
cmake -D CMAKE_INSTALL_PREFIX=/usr     \
      -D CMAKE_INSTALL_LIBDIR=lib32    \
      -D CMAKE_BUILD_TYPE=Release      \
      -D SPIRV_WERROR=OFF              \
      -D BUILD_SHARED_LIBS=ON          \
      -D SPIRV_TOOLS_BUILD_STATIC=OFF  \
      -D SPIRV-Headers_SOURCE_DIR=/usr \
      -G Ninja ..
      
ninja
DESTDIR=$PWD/DESTDIR ninja install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
ldconfig
