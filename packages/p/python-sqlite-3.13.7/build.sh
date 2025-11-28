
CXX="/usr/bin/g++"               \
./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --enable-optimizations --without-static-libpython

make

make DESTDIR=$PCKDIR install

