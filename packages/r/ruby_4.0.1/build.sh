
./configure --prefix=/usr         \
            --disable-rpath       \
            --enable-shared       \
            --without-valgrind    \
            --without-baseruby    \
            ac_cv_func_qsort_r=no \
            --docdir=/usr/share/doc/ruby-4.0.1

make

make DESTDIR=$PCKDIR install
