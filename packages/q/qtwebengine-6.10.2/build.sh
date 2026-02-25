#!/bin/bash

sed -e '/ifndef SYS_SECCOMP/,+2 d' \
    -i src/3rdparty/chromium/sandbox/linux/system_headers/linux_seccomp.h

mkdir -p build
cd       build

cmake -D CMAKE_MESSAGE_LOG_LEVEL=STATUS             \
      -D QT_FEATURE_webengine_system_ffmpeg=ON      \
      -D QT_FEATURE_webengine_system_icu=ON         \
      -D QT_FEATURE_webengine_system_libevent=ON    \
      -D QT_FEATURE_webengine_proprietary_codecs=ON \
      -D QT_FEATURE_webengine_webrtc_pipewire=ON    \
      -D QT_BUILD_EXAMPLES_BY_DEFAULT=OFF           \
      -D QT_GENERATE_SBOM=OFF                       \
      -G Ninja .. 
      
ninja
DESTDIR=$PCKDIR ninja install
