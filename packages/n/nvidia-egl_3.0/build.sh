cat > nvidia-egl-list << "EOF"
eglexternalplatform/archive/1.2.1/eglexternalplatform-1.2.1.tar.gz
egl-gbm/archive/1.1.2.1/egl-gbm-1.1.2.1.tar.gz
egl-wayland/archive/1.1.20/egl-wayland-1.1.20.tar.gz
egl-x11/archive/v1.0.4/egl-x11-1.0.4.tar.gz
EOF

mkdir nvidia-egl &&
cd nvidia-egl &&
grep -v '^#' ../nvidia-egl-list | wget -i- -c \
    -B https://github.com/NVIDIA/


for package in $(grep -v '^#' ../nvidia-egl-list)
do
  package=$(basename "$package")
  packagedir=${package%.tar.?z*}
  tar -xf $package
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
