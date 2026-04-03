#!/bin/bash

tar -xf ../udis86-5336633af70f3917760a6d441ff02d93477b0c86.tar.gz 
mv -T udis86-5336633af70f3917760a6d441ff02d93477b0c86 subprojects/udis86

cat > glz-version.cpp << "EOF"
#include <glaze/glaze.hpp>
#include <glaze/version.hpp>
#include <stdio.h>
int main() {
  printf("%i.%i.%i\n", glz::version.major,
                       glz::version.minor,
                       glz::version.patch);
  return 0;
}
EOF

g++ -std=c++23 -o glz-version glz-version.cpp &&
sed -i "s/glaze\ [0-9][0-9.]*/glaze\ $(./glz-version)/" \
  hyprpm/CMakeLists.txt &&
rm -vf glz-version{,.cpp}

mkdir -p build
cd       build

cmake -D CMAKE_INSTALL_PREFIX=/usr   \
      -D CMAKE_BUILD_TYPE=Release    \
      -D CMAKE_SKIP_INSTALL_RPATH=ON \
      -D BUILD_TESTING=OFF           \
      -W no-dev -G Ninja ..

ninja
DESTDIR=$PCKDIR ninja install

ln -sfv start-hyprland $PCKDIR/usr/bin/hyprland

