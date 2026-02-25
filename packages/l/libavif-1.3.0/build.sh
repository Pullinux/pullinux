#!/bin/bash

sed 's/enable_adaptive_quantization/aq_mode/' -i src/codec_svt.c

mkdir -p build
cd       build

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D AVIF_CODEC_AOM=SYSTEM     \
      -D AVIF_CODEC_DAV1D=SYSTEM   \
      -D AVIF_CODEC_SVT=SYSTEM     \
      -D AVIF_BUILD_GDK_PIXBUF=OFF \
      -D AVIF_LIBYUV=OFF           \
      -G Ninja ..

ninja
DESTDIR=$PCKDIR ninja install
