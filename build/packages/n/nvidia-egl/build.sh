
for package in $(grep -v '^#' $PCKBASE/files/nvidia-egl-list)
do
  package=$(basename "$package")
  packagedir=${package%.tar.?z*}
  tar -xf $PCKBASE/files/$package
  pushd $packagedir
     mkdir build
     cd    build
       meson setup --prefix=/usr       \
                   --buildtype=release \
                   ..
       ninja
       DESTDIR=$PCKDIR ninja install
       ninja install
  popd
  rm -rf $packagedir
  /sbin/ldconfig
done
