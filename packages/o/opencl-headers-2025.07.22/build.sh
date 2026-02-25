cat > ocl-headers-list << "EOF"
OpenCL-Headers/archive/v2025.07.22/OpenCL-Headers-2025.07.22.tar.gz
OpenCL-CLHPP/archive/v2025.07.22/OpenCL-CLHPP-2025.07.22.tar.gz
EOF

mkdir ocl-headers &&
cd    ocl-headers &&
grep -v '^#' ../ocl-headers-list | wget -i- -c \
    -B https://github.com/KhronosGroup/

for package in OpenCL-{Headers,CLHPP}
do
  longpackage=$package-2025.07.22.tar.?z*
  packagedir=${longpackage%.tar.?z*}
  tar -xf $longpackage
  pushd $packagedir
    mkdir build
    cd    build
    cmake -D CMAKE_INSTALL_PREFIX=/usr \
          -D CMAKE_BUILD_TYPE=Release  \
          -D BUILD_TESTING=OFF         \
          -D BUILD_EXAMPLES=OFF        \
          -G Ninja ..
    DESTDIR=$PCKDIR ninja install
    ninja install
  popd
  rm -rf $packagedir
done
