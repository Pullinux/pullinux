#!/bin/bash

mkdir -p build
cd       build

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D SDL_TEST_LIBRARY=OFF      \
      -D SDL_STATIC=OFF            \
      -D SDL_RPATH=OFF             \
      -W no-dev -G Ninja ..

ninja
DESTDIR=$PCKDIR ninja install
