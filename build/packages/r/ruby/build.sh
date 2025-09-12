
./configure --prefix=/usr         \
            --disable-rpath       \
            --enable-shared       \
            --without-valgrind    \
            --without-baseruby    \
            ac_cv_func_qsort_r=no \
            --docdir=/usr/share/doc/ruby-3.4.5

make

make capi

make DESTDIR=$PCKDIR install

