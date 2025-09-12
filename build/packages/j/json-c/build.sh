sed -i 's/VERSION 2.8/VERSION 4.0/' apps/CMakeLists.txt  &&
sed -i 's/VERSION 3.9/VERSION 4.0/' tests/CMakeLists.txt

mkdir -v __build 
cd       __build 

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D BUILD_STATIC_LIBS=OFF     \
      ..

make

make DESTDIR=$PCKDIR install

