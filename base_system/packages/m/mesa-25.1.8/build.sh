
mkdir build 
cd    build 

meson setup ..                 \
      --prefix=$XORG_PREFIX    \
      --buildtype=release      \
      -D platforms=x11,wayland \
      -D gles1=disabled        \
      -D gallium-drivers=radeonsi,iris,llvmpipe,nouveau,svga,virgl,i915,r300,r600  \
      -D vulkan-drivers=amd,intel,nouveau,swrast   \
      -D valgrind=disabled     \
      -D libunwind=disabled    \
      -D video-codecs=all      

ninja

DESTDIR=$PCKDIR ninja install


#32bit
mkdir -p $PCKDIR/usr/lib32
rm -rf ./*

meson setup                    \
      --cross-file=lib32       \
      --prefix=/usr            \
      --libdir=/usr/lib32      \
      --buildtype=release      \
      -D platforms=x11,wayland \
      -D gallium-drivers=radeonsi,iris,llvmpipe,nouveau,svga,virgl,i915,r300,r600  \
      -D vulkan-drivers=amd,intel,nouveau,swrast   \
      -D gles1=disabled        \
      -D video-codecs=all      \
      -D valgrind=disabled     \
      .. &&
      sed -i 's/\/usr\/lib\//\/usr\/lib32\//g' ./build.ninja &&

BINDGEN_EXTRA_CLANG_ARGS="-m32" ninja

ninja
DESTDIR=$PWD/DESTDIR ninja install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
if [ -d DESTDIR/usr/share/vulkan ]; then
    mkdir -p $PCKDIR/usr/share
    cp -vR DESTDIR/usr/share/vulkan $PCKDIR/usr/share
fi                                                     
rm -rf DESTDIR
ldconfig
