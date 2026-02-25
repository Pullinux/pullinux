cat > font-7-list << "EOF"
font-util-1.4.1.tar.xz
encodings-1.1.0.tar.xz
font-alias-1.0.6.tar.xz
font-adobe-utopia-type1-1.0.5.tar.xz
font-bh-ttf-1.0.4.tar.xz
font-bh-type1-1.0.4.tar.xz
font-ibm-type1-1.0.4.tar.xz
font-misc-ethiopic-1.0.5.tar.xz
font-xfree86-type1-1.0.5.tar.xz
EOF

mkdir font &&
cd font &&
grep -v '^#' ../font-7-list | wget -i- -c \
    -B https://xorg.freedesktop.org/archive/individual/font/

for package in $(grep -v '^#' ../font-7-list)
do
  packagedir=${package%.tar.?z*}
  tar -xf $package
  pushd $packagedir
    echo "Running configure for $(pwd)"
    ./configure $XORG_CONFIG
    echo "Done Configure... Building..."
    
    make
    make install
    make DESTDIR=$PCKDIR install
  popd
  rm -rf $packagedir
done

