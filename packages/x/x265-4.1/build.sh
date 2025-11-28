sed -r '/cmake_policy.*(0025|0054)/d' -i source/CMakeLists.txt

mkdir bld &&
cd    bld &&

cmake -D CMAKE_INSTALL_PREFIX=/usr        \
      -D GIT_ARCHETYPE=1                  \
      -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -W no-dev                           \
      ../source   
make

make DESTDIR=$PCKDIR install

rm -vf $PCKDIR/usr/lib/libx265.a
