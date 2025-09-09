


mkdir obj &&
cd    obj &&

../js/src/configure --prefix=/usr            \
                    --disable-debug-symbols  \
                    --disable-jemalloc       \
                    --enable-readline        \
                    --enable-rust-simd       \
                    --with-intl-api          \
                    --with-system-icu        \
                    --with-system-zlib   

make

make DESTDIR=$PCKDIR install

rm -v $PCKDIR/usr/lib/libjs_static.ajs
sed -i '/@NSPR_CFLAGS@/d' $PCKDIR/usr/bin/js140-config

sed '$i#define XP_UNIX' -i $PCKDIR/usr/include/mozjs-140/js-config.h
