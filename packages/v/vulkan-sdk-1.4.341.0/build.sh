cat > vulkan-sdk-1.4.341.0-list << "EOF"
Vulkan-Headers/archive/vulkan-sdk-1.4.341.0/Vulkan-Headers-vulkan-sdk-1.4.341.0.tar.gz
Vulkan-Loader/archive/vulkan-sdk-1.4.341.0/Vulkan-Loader-vulkan-sdk-1.4.341.0.tar.gz
SPIRV-Headers/archive/vulkan-sdk-1.4.341.0/SPIRV-Headers-vulkan-sdk-1.4.341.0.tar.gz
SPIRV-Tools/archive/vulkan-sdk-1.4.341.0/SPIRV-Tools-vulkan-sdk-1.4.341.0.tar.gz
glslang/archive/vulkan-sdk-1.4.341.0/glslang-vulkan-sdk-1.4.341.0.tar.gz
EOF


mkdir vulkan-sdk-1.4.341.0 &&
cd    vulkan-sdk-1.4.341.0 &&
grep -v '^#' ../vulkan-sdk-1.4.341.0-list | wget -i- -c \
    -B https://github.com/KhronosGroup/



for package in {Vulkan-{Headers,Loader},SPIRV-{Headers,Tools},glslang}
do
  longpackage=$package-vulkan-sdk-1.4.341.0.tar.?z*
  packagedir=${longpackage%.tar.?z*}
  tar -xf $longpackage
  pushd $packagedir
    mkdir build
    cd    build
    case $package in
      SPIRV-Tools )
        cmake -D CMAKE_INSTALL_PREFIX=/usr     \
              -D CMAKE_BUILD_TYPE=Release      \
              -D SPIRV_WERROR=OFF              \
              -D BUILD_SHARED_LIBS=ON          \
              -D SPIRV_TOOLS_BUILD_STATIC=OFF  \
              -D SPIRV-Headers_SOURCE_DIR=/usr \
              -G Ninja ..
      ;;
      glslang )
        cmake -D CMAKE_INSTALL_PREFIX=/usr     \
              -D CMAKE_BUILD_TYPE=Release      \
              -D ALLOW_EXTERNAL_SPIRV_TOOLS=ON \
              -D BUILD_SHARED_LIBS=ON          \
              -D GLSLANG_TESTS=OFF             \
              -G Ninja ..
      ;;
      * )
        cmake -D CMAKE_INSTALL_PREFIX=/usr     \
              -D CMAKE_BUILD_TYPE=Release      \
              -D CMAKE_SKIP_INSTALL_RPATH=ON   \
              -G Ninja ..
      ;;
    esac
    ninja
    DESTDIR=$PCKDIR ninja install
    ninja install
  popd
  rm -rf $packagedir
done


for package in {Vulkan-Loader,SPIRV-Tools,glslang}
do
  longpackage=$package-vulkan-sdk-1.4.341.0.tar.?z*
  packagedir=${longpackage%.tar.?z*}
  tar -xf $longpackage
  pushd $packagedir
    mkdir build
    cd    build
    case $package in
      SPIRV-Tools )
        CC="gcc -m32" CXX="g++ -m32"           \
        PKG_CONFIG_PATH=/usr/lib32/pkgconfig   \
        cmake -D CMAKE_INSTALL_PREFIX=/usr     \
              -D CMAKE_INSTALL_LIBDIR=lib32    \
              -D CMAKE_BUILD_TYPE=Release      \
              -D SPIRV_WERROR=OFF              \
              -D BUILD_SHARED_LIBS=ON          \
              -D SPIRV_TOOLS_BUILD_STATIC=OFF  \
              -D SPIRV-Headers_SOURCE_DIR=/usr \
              -G Ninja ..
      ;;
      glslang )
        CC="gcc -m32" CXX="g++ -m32"           \
        PKG_CONFIG_PATH=/usr/lib32/pkgconfig   \
        cmake -D CMAKE_INSTALL_PREFIX=/usr     \
              -D CMAKE_INSTALL_LIBDIR=lib32    \
              -D CMAKE_BUILD_TYPE=Release      \
              -D ALLOW_EXTERNAL_SPIRV_TOOLS=ON \
              -D BUILD_SHARED_LIBS=ON          \
              -D GLSLANG_TESTS=OFF             \
              -G Ninja ..
      ;;
      * )
        ASFLAGS+=" --32" CFLAGS+=" -m32"       \
        CXXFLAGS+=" -m32"                      \
        PKG_CONFIG_PATH=/usr/lib32/pkgconfig   \
        cmake -D CMAKE_INSTALL_PREFIX=/usr     \
              -D CMAKE_INSTALL_LIBDIR=lib32    \
              -D CMAKE_BUILD_TYPE=Release      \
              -D CMAKE_SKIP_INSTALL_RPATH=ON   \
              -G Ninja ..
      ;;
    esac
    ninja
    mkdir -p $PCKDIR/usr/lib32
    DESTDIR=$PWD/DESTDIR ninja install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
    rm -rf DESTDIR
    /sbin/ldconfig
  popd
  rm -rf $packagedir
done


