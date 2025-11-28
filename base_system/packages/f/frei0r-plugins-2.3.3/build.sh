
mkdir -v __build 
cd       __build 

cmake -D CMAKE_INSTALL_PREFIX=/usr        \
      -D CMAKE_BUILD_TYPE=Release         \
      -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -W no-dev .. 

make

make DESTDIR=$PCKDIR install

