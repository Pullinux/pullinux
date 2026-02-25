#!/bin/bash

cat > llvm-21.1.8-list << "EOF"
# The three tarballs below are required
llvm-21.1.8.src.tar.xz
cmake-21.1.8.src.tar.xz
third-party-21.1.8.src.tar.xz

# The following clang tarball is for Clang (Recommended)
clang-21.1.8.src.tar.xz

# The following compiler-rt tarball is for Compiler RT (Recommended)
compiler-rt-21.1.8.src.tar.xz
EOF

mkdir llvm &&
cd llvm &&
grep -v '^#' ../llvm-21.1.8-list | wget -i- -c \
    -B https://github.com/llvm/llvm-project/releases/download/llvmorg-21.1.8/


tar -xf llvm-21.1.8.src.tar.xz 
cd llvm-21.1.8.src

tar -xf ../cmake-21.1.8.src.tar.xz &&
tar -xf ../third-party-21.1.8.src.tar.xz &&
sed '/LLVM_COMMON_CMAKE_UTILS/s@../cmake@cmake-21.1.8.src@' \
    -i CMakeLists.txt &&
sed '/LLVM_THIRD_PARTY_DIR/s@../third-party@third-party-21.1.8.src@' \
    -i cmake/modules/HandleLLVMOptions.cmake


tar -xf ../clang-21.1.8.src.tar.xz -C tools &&
mv tools/clang-21.1.8.src tools/clang

tar -xf ../compiler-rt-21.1.8.src.tar.xz -C projects    &&
mv projects/compiler-rt-21.1.8.src projects/compiler-rt

grep -rl '#!.*python' | xargs sed -i '1s/python$/python3/'

sed 's/utility/tool/' -i utils/FileCheck/CMakeLists.txt

mkdir build &&
cd    build &&

CC=gcc CXX=g++                                         \
cmake -D CMAKE_INSTALL_PREFIX=/usr                     \
      -D CMAKE_SKIP_INSTALL_RPATH=ON                   \
      -D LLVM_ENABLE_FFI=ON                            \
      -D CMAKE_BUILD_TYPE=Release                      \
      -D LLVM_BUILD_LLVM_DYLIB=ON                      \
      -D LLVM_LINK_LLVM_DYLIB=ON                       \
      -D LLVM_ENABLE_RTTI=ON                           \
      -D LLVM_TARGETS_TO_BUILD="X86;host;AMDGPU;NVPTX" \
      -D LLVM_BINUTILS_INCDIR=/usr/include             \
      -D LLVM_INCLUDE_BENCHMARKS=OFF                   \
      -D CLANG_DEFAULT_PIE_ON_LINUX=ON                 \
      -D CLANG_CONFIG_FILE_SYSTEM_DIR=/etc/clang       \
      -W no-dev -G Ninja .. 

ninja

DESTDIR=$PCKDIR ninja install

rm -rf * &&

CC=gcc CXX=g++                                          \
cmake -D CMAKE_INSTALL_PREFIX=/usr                      \
      -D CMAKE_C_FLAGS:STRING=-m32                      \
      -D CMAKE_SKIP_INSTALL_RPATH=ON                    \
      -D CMAKE_CXX_FLAGS:STRING=-m32                    \
      -D LLVM_TARGET_ARCH:STRING=i686                   \
      -D LLVM_LIBDIR_SUFFIX=32                          \
      -D LLVM_ENABLE_FFI=ON                             \
      -D CMAKE_BUILD_TYPE=Release                       \
      -D LLVM_BUILD_LLVM_DYLIB=ON                       \
      -D LLVM_LINK_LLVM_DYLIB=ON                        \
      -D LLVM_ENABLE_RTTI=ON                            \
      -D LLVM_DEFAULT_TARGET_TRIPLE="i686-pc-linux-gnu" \
      -D LLVM_TARGETS_TO_BUILD="X86;host;AMDGPU;NVPTX"  \
      -D LLVM_HOST_TRIPLE="x86_64-pc-linux-gnu"         \
      -D LLVM_BINUTILS_INCDIR=/usr/include              \
      -D LLVM_INCLUDE_BENCHMARKS=OFF                    \
      -D CLANG_DEFAULT_PIE_ON_LINUX=ON                  \
      -D CLANG_CONFIG_FILE_SYSTEM_DIR=/etc/clang        \
      -W no-dev -G Ninja .. 

ninja

mkdir -p $PCKDIR/usr/lib32 

DESTDIR=$PWD/DESTDIR ninja install    &&
cp -vr DESTDIR/usr/lib32/* $PCKDIR/usr/lib32 

mkdir -pv $PCKDIR/etc/clang &&
for i in clang clang++; do
  echo -fstack-protector-strong > $PCKDIR/etc/clang/$i.cfg
done

