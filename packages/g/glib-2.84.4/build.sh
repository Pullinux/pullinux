
patch -Np1 -i $PCKBASE/files/glib-skip_warnings-1.patch

mkdir __build && cd __build
meson setup ..                  \
      --prefix=/usr             \
      --buildtype=release       \
      -D introspection=disabled \
      -D glib_debug=disabled    \
      -D man-pages=disabled     \
      -D tests=false            \
      -D sysprof=disabled      
ninja

DESTDIR=$PCKDIR ninja install

ninja install

tar xf $PCKBASE/files/gobject-introspection-1.84.0.tar.xz 

meson setup gobject-introspection-1.84.0 gi-build \
            --prefix=/usr --buildtype=release     
ninja -C gi-build

DESTDIR=$PCKDIR ninja -C gi-build install

ninja -C gi-build install

meson configure -D introspection=enabled &&
ninja
DESTDIR=$PCKDIR ninja install

#32bit
mkdir -p $PCKDIR/usr/lib32
rm -rf * 
meson setup ..                  \
      --cross-file=lib32        \
      --prefix=/usr             \
      --libdir=/usr/lib32       \
      --buildtype=release       \
      -D introspection=disabled \
      -D glib_debug=disabled    \
      -D man-pages=disabled     \
      -D tests=false            \
      -D sysprof=disabled


ninja

DESTDIR=$PWD/DESTDIR ninja install    
cp -vR DESTDIR/usr/lib32/* $PCKDIR/usr/lib32 
rm -rf DESTDIR                        
ldconfig
