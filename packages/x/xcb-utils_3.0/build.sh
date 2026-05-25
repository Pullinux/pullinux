
cat > xcb-utils-list << "EOF"
xcb-util-0.4.1.tar.xz
xcb-util-image-0.4.1.tar.xz
xcb-util-keysyms-0.4.1.tar.xz
xcb-util-renderutil-0.3.10.tar.xz
xcb-util-wm-0.4.2.tar.xz
xcb-util-cursor-0.1.6.tar.xz
EOF

mkdir xcb-utils &&
cd xcb-utils &&
grep -v '^#' ../xcb-utils-list | wget -i- -c \
    -B https://xorg.freedesktop.org/archive/individual/lib/


for package in $(grep -v '^#' ../xcb-utils-list)
do
  packagedir=${package%.tar.?z*}
  tar -xf $package
  pushd $packagedir
     ./configure $XORG_CONFIG
     make
     make DESTDIR=$PCKDIR install
     make install
  popd
  rm -rf $packagedir
done

