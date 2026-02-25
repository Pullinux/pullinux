cat > lib-7-list << "EOF"
xtrans-1.6.0.tar.xz
libX11-1.8.13.tar.xz
libXext-1.3.7.tar.xz
#libFS-1.0.10.tar.xz
libICE-1.1.2.tar.xz
libSM-1.2.6.tar.xz
libXScrnSaver-1.2.5.tar.xz
libXt-1.3.1.tar.xz
libXmu-1.3.1.tar.xz
libXpm-3.5.18.tar.xz
libXaw-1.0.16.tar.xz
libXfixes-6.0.2.tar.xz
libXcomposite-0.4.7.tar.xz
libXrender-0.9.12.tar.xz
libXcursor-1.2.3.tar.xz
libXdamage-1.1.7.tar.xz
libfontenc-1.1.9.tar.xz
libXfont2-2.0.7.tar.xz
libXft-2.3.9.tar.xz
libXi-1.8.2.tar.xz
libXinerama-1.1.6.tar.xz
libXrandr-1.5.5.tar.xz
libXres-1.2.3.tar.xz
libXtst-1.2.5.tar.xz
libXv-1.0.13.tar.xz
libXvMC-1.0.15.tar.xz
libXxf86dga-1.1.7.tar.xz
libXxf86vm-1.1.7.tar.xz
libpciaccess-0.18.1.tar.xz
libxkbfile-1.2.0.tar.xz
libxshmfence-1.3.3.tar.xz
libXpresent-1.0.2.tar.xz
EOF

mkdir lib &&
cd lib &&
grep -v '^#' ../lib-7-list | wget -i- -c \
    -B https://xorg.freedesktop.org/archive/individual/lib/


for package in $(grep -v '^#' ../lib-7-list)
do
  packagedir=${package%.tar.?z*}
  echo "Building $packagedir"

  tar -xf $package
  pushd $packagedir
  docdir="--docdir=/usr/share/doc/$packagedir"

  do_build()   { make; }
  do_install() { make DESTDIR=$PCKDIR install; make install; }

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

    libpciaccess* | libxkbfile*)
      meson setup --prefix=/usr --buildtype=release build
      do_build()   { ninja -C build; }
      do_install() { DESTDIR=$PCKDIR ninja -C build install; ninja -C build install; }
    ;;

    * )
      ./configure $XORG_CONFIG $docdir
    ;;
  esac

  do_build
  do_install
  unset do_build do_install

  popd
  rm -rf $packagedir
  /sbin/ldconfig

done



for package in $(grep -v '^#' ../lib-7-list)
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

  do_build()        { make; }
  do_dest_install() { make DESTDIR=$PWD/DESTDIR install; }

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

    libpciaccess* | libxkbfile* )
      CC="gcc -m32" CXX="g++ -m32" PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
      meson setup --prefix=/usr $libdir --buildtype=release build

      do_build()        { ninja -C build; }
      do_dest_install() { DESTDIR=$PWD/DESTDIR ninja -C build install; }
    ;;

    * )
      CC="gcc -m32" CXX="g++ -m32"                   \
      PKG_CONFIG_PATH=/usr/lib32/pkgconfig   \
      ./configure $XORG_CONFIG $libdir $host $docdir
    ;;
  esac

  do_build
  do_dest_install
  unset do_build do_dest_install

  mkdir -p $PCKDIR/usr/lib32
  cp -vR DESTDIR/usr/lib32/* /usr/lib32
  cp -vR DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
  rm -rf DESTDIR
  popd
  rm -rf $packagedir
  /sbin/ldconfig
done

