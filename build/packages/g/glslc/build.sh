sed '/build-version/d'   -i glslc/CMakeLists.txt            
sed '/third_party/d'     -i CMakeLists.txt                  
sed 's|SPIRV|glslang/&|' -i libshaderc_util/src/compiler.cc 

echo '"2025.3"' > glslc/src/build-version.inc

mkdir __build && cd __build
cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D SHADERC_SKIP_TESTS=ON     \
      -G Ninja ..
ninja

mkdir -p $PCKDIR/usr/bin/

install -vm755 glslc/glslc $PCKDIR/usr/bin
