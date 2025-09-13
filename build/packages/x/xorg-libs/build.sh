
for package in $(grep -v '^#' lib-7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.?z*}
  echo "Building $packagedir"

  tar -xf $package
  pushd $packagedir
  docdir="--docdir=$XORG_PREFIX/share/doc/$packagedir"
  
  case $packagedir in
    libXfont2-[0-9]* )
      ./configure $XORG_CONFIG $docdir --disable-devel-docs
    ;;

    libXt-[0-9]* )
      ./configure $XORG_CONFIG $docdir \
                  --with-appdefaultdir=/etc/X11/app-defaults
    ;;

    libXpm-[0-9]* )
      ./configure $XORG_CONFIG $docdir --disable-open-zfile
    ;;
  
    libpciaccess* )
      mkdir build
      cd    build
        meson setup --prefix=$XORG_PREFIX --buildtype=release ..
        ninja
        DESTDIR=$PCKDIR ninja install
        ninja install
      popd
      continue
    ;;

    * )
      ./configure $XORG_CONFIG $docdir
    ;;
  esac

  make
  make DESTDIR=$PCKDIR install
  make install
  popd
  rm -rf $packagedir
  /sbin/ldconfig
done


#32bit
mkdir -p $PCKDIR/usr/lib32

for package in $(grep -v '^#' lib-7.md5 | awk '{print $2}')
do

  case $package in xtrans* )
    continue
  ;;
  esac

  packagedir=${package%.tar.?z*}
  echo "Building lib32-$packagedir"

  tar -xf $package
  pushd $packagedir
  libdir="--libdir=/usr/lib32"
  docdir="--docdir=/usr/share/doc/$packagedir"
  host="--host=i686-pc-linux-gnu"
  
  case $packagedir in
    libXfont2-[0-9]* )
      CC="gcc -m32" CXX="g++ -m32" PKG_CONFIG_PATH=/usr/lib32/pkgconfig  \
      ./configure $XORG_CONFIG $libdir $host $docdir --disable-devel-docs
    ;;

    libXt-[0-9]* )
      CC="gcc -m32" CXX="g++ -m32" PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
      ./configure $XORG_CONFIG $libdir $host $docdir                    \
                  --with-appdefaultdir=/etc/X11/app-defaults
    ;;

    libXpm-[0-9]* )
      CC="gcc -m32" CXX="g++ -m32" PKG_CONFIG_PATH=/usr/lib32/pkgconfig  \
      ./configure $XORG_CONFIG $libdir $host $docdir --disable-open-zfile
    ;;
  
    libpciaccess* )
      mkdir build
      cd    build
        CC="gcc -m32" CXX="g++ -m32" PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
        meson setup --prefix=/usr $libdir --buildtype=release ..
        ninja
        DESTDIR=$PWD/DESTDIR ninja install
        cp -vr DESTDIR/usr/lib32/* /usr/lib32
        cp -vr DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
        /sbin/ldconfig

      popd
      continue
    ;;

    * )
      CC="gcc -m32" CXX="g++ -m32"                   \
      PKG_CONFIG_PATH=/usr/lib32/pkgconfig   \
      ./configure $XORG_CONFIG $libdir $host $docdir
    ;;
  esac

  make
  make DESTDIR=$PWD/DESTDIR install
  cp -vr DESTDIR/usr/lib32/* /usr/lib32
  cp -vr DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
  rm -rf DESTDIR
  popd
  rm -rf $packagedir
  /sbin/ldconfig
done
