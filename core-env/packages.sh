
pck_build_manpages() {
    rm -v man3/crypt*
    make -R GIT=false prefix=/usr install
}

pck_build_ianaetc() {
    cp -v services protocols /etc
}

pck_build_glibc() {
    patch -Np1 -i /sources/glibc-fhs-1.patch
    patch -Np1 -i /sources/glibc-2.44-upstream_fixes-1.patch

    mkdir build
    cd build

    ../configure --prefix=/usr                   \
             --disable-werror                \
             --disable-nscd                  \
             libc_cv_slibdir=/usr/lib        \
             --enable-stack-protector=strong \
             --enable-kernel=5.10

    make
    touch /etc/ld.so.conf
    sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

    make install
    sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd

    localedef -i C -f UTF-8 C.UTF-8
    localedef -i en_US -f ISO-8859-1 en_US
    localedef -i en_US -f UTF-8 en_US.UTF-8

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files systemd
group: files systemd
shadow: files systemd

hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

    tar -xf /sources/tzdata2026c.tar.gz

    ZONEINFO=/usr/share/zoneinfo
    mkdir -pv $ZONEINFO/{posix,right}

    for tz in etcetera southamerica northamerica europe africa antarctica  \
            asia australasia backward; do
        zic -L /dev/null   -d $ZONEINFO       ${tz}
        zic -L /dev/null   -d $ZONEINFO/posix ${tz}
        zic -L leapseconds -d $ZONEINFO/right ${tz}
    done

    cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
    zic -d $ZONEINFO -p America/New_York
    unset ZONEINFO tz

    ln -sfv /usr/share/zoneinfo/America/Chicago /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF

    mkdir -pv /etc/ld.so.conf.d

    #build 32 bit
    rm -rf ./*
    find .. -name "*.a" -delete

    CC="gcc -m32" CXX="g++ -m32"             \
    ../configure                             \
        --prefix=/usr                      \
        --host=i686-pc-linux-gnu           \
        --build=$(../scripts/config.guess) \
        --libdir=/usr/lib32                \
        --libexecdir=/usr/lib32            \
        --disable-werror                   \
        --disable-nscd                     \
        libc_cv_slibdir=/usr/lib32         \
        --enable-stack-protector=strong    \
        --enable-kernel=5.10

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -a DESTDIR/usr/lib32/* /usr/lib32/
    install -vm644 DESTDIR/usr/include/gnu/{lib-names,stubs}-32.h \
                /usr/include/gnu/
    
    echo "/usr/lib32" > /etc/ld.so.conf.d/lib32.conf

}

pck_build_zlib() {
    ./configure --prefix=/usr
    make
    make install
    make distclean
    CFLAGS+=" -m32" CXXFLAGS+=" -m32" \
    ./configure --prefix=/usr --libdir=/usr/lib32
    make
    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_bzip2() {
    patch -Np1 -i /sources/bzip2-1.0.8-install_docs-1.patch
    sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile

    sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

    make -f Makefile-libbz2_so
    make clean
    make

    make PREFIX=/usr install

    cp -av libbz2.so.* /usr/lib
    ln -sfv libbz2.so.1.0.8 /usr/lib/libbz2.so

    ln -sfv libbz2.so.1.0.8 /usr/lib/libbz2.so.1

    cp -v bzip2-shared /usr/bin/bzip2
    for i in /usr/bin/{bzcat,bunzip2}; do
    ln -sfv bzip2 $i
    done

    make clean
    make -f Makefile-libbz2_so clean

    sed -e "s/^CC=.*/CC=gcc -m32/" -i Makefile{,-libbz2_so}
    make -f Makefile-libbz2_so

    install -Dm755 libbz2.so.1.0.8 /usr/lib32/libbz2.so.1.0.8
    ln -svf libbz2.so.1.0.8 /usr/lib32/libbz2.so
    ln -svf libbz2.so.1.0.8 /usr/lib32/libbz2.so.1
    ln -svf libbz2.so.1.0.8 /usr/lib32/libbz2.so.1.0

}

pck_build_xz() {
    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/xz-5.8.3


    make

    make install

    make distclean

    CC="gcc -m32" ./configure         \
        --host=i686-pc-linux-gnu      \
        --prefix=/usr                 \
        --libdir=/usr/lib32           \
        --disable-static

    make
    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_lz4() {
    make BUILD_STATIC=no PREFIX=/usr

    make BUILD_STATIC=no PREFIX=/usr install

    make clean

    CC="gcc -m32" make BUILD_STATIC=no -C lib

    make BUILD_STATIC=no    \
        PREFIX=/usr        \
        LIBDIR=/usr/lib32  \
        DESTDIR=$(pwd)/m32 \
        -C lib install
    cp -vR m32/usr/lib32/* /usr/lib32/

}

pck_build_zstd() {
    make prefix=/usr

    make prefix=/usr install

    rm -v /usr/lib/libzstd.a

    make clean

    CC="gcc -m32" make prefix=/usr

    make prefix=/usr DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib/* /usr/lib32/
    sed -e "/^libdir/s/lib$/lib32/" -i /usr/lib32/pkgconfig/libzstd.pc
    rm -rf DESTDIR

}

pck_build_file() {
    ./configure --prefix=/usr

    make

    make install

    make distclean

    CC="gcc -m32" ./configure \
        --prefix=/usr         \
        --libdir=/usr/lib32   \
        --host=i686-pc-linux-gnu

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR

}

pck_build_readline() {
    sed -i '/MV.*old/d' Makefile.in
    sed -i '/{OLDSUFF}/c:' support/shlib-install

    sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf

    sed -e '270a\
        else\
        chars_avail = 1;'      \
        -e '288i\   result = -1;' \
        -i.orig input.c

    ./configure --prefix=/usr    \
                --disable-static \
                --with-curses    \
                --docdir=/usr/share/doc/readline-8.3

    make SHLIB_LIBS="-lncursesw"

    make install

    install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.3

    make distclean

    CC="gcc -m32" ./configure         \
        --host=i686-pc-linux-gnu      \
        --prefix=/usr                 \
        --libdir=/usr/lib32           \
        --disable-static              \
        --with-curses

    make SHLIB_LIBS="-lncursesw"

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_pcre2() {
    ./configure --prefix=/usr                       \
            --docdir=/usr/share/doc/pcre2-10.47 \
            --enable-unicode                    \
            --enable-jit                        \
            --enable-pcre2-16                   \
            --enable-pcre2-32                   \
            --enable-pcre2grep-libz             \
            --enable-pcre2grep-libbz2           \
            --enable-pcre2test-libreadline      \
            --disable-static

    make
    make install

    make distclean

    CC="gcc -m32" CXX="g++ -m32"               \
    ./configure --prefix=/usr                  \
                --libdir=/usr/lib32            \
                --host=i686-pc-linux-gnu       \
                --enable-unicode               \
                --enable-jit                   \
                --enable-pcre2-16              \
                --enable-pcre2-32              \
                --enable-pcre2grep-libz        \
                --enable-pcre2grep-libbz2      \
                --enable-pcre2test-libreadline \
                --disable-static

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_m4() {
    ./configure --prefix=/usr
    make
    make install

}

pck_build_bc() {
    CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r
    make
    make install
}

pck_build_flex() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/flex-2.6.4

    make

    make install

    ln -sv flex   /usr/bin/lex
    ln -sv flex.1 /usr/share/man/man1/lex.1

}

pck_build_tcl() {
    SRCDIR=$(pwd)
    cd unix
    ./configure --prefix=/usr           \
                --mandir=/usr/share/man \
                --disable-rpath

    make

    sed -e "s|$SRCDIR/unix|/usr/lib|" \
        -e "s|$SRCDIR|/usr/include|"  \
        -i tclConfig.sh

    sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.13|/usr/lib/tdbc1.1.13|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.13/generic|/usr/include|"     \
        -e "s|$SRCDIR/pkgs/tdbc1.1.13/library|/usr/lib/tcl8.6|"  \
        -e "s|$SRCDIR/pkgs/tdbc1.1.13|/usr/include|"             \
        -i pkgs/tdbc1.1.13/tdbcConfig.sh

    sed -e "s|$SRCDIR/unix/pkgs/itcl4.3.7|/usr/lib/itcl4.3.7|" \
        -e "s|$SRCDIR/pkgs/itcl4.3.7/generic|/usr/include|"    \
        -e "s|$SRCDIR/pkgs/itcl4.3.7|/usr/include|"            \
        -i pkgs/itcl4.3.7/itclConfig.sh

    unset SRCDIR

    make install 
    chmod 644 /usr/lib/libtclstub8.6.a

    chmod -v u+w /usr/lib/libtcl8.6.so

    make install-private-headers

    ln -sfv tclsh8.6 /usr/bin/tclsh

    mv -v /usr/share/man/man3/{Thread,Tcl_Thread}.3

    cd ..
    tar -xf /sources/tcl8.6.18-html.tar.gz --strip-components=1
    mkdir -v -p /usr/share/doc/tcl-8.6.18
    cp -v -r  ./html/* /usr/share/doc/tcl-8.6.18
}

pck_build_expect() {
    python3 -c 'from pty import spawn; spawn(["echo", "ok"])'

    patch -Np1 -i /sources/expect-5.45.4-gcc15-1.patch

    ./configure --prefix=/usr           \
                --with-tcl=/usr/lib     \
                --enable-shared         \
                --disable-rpath         \
                --mandir=/usr/share/man \
                --with-tclinclude=/usr/include
    
    make
    make install
    ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

}

pck_build_dejagnu() {
    mkdir -v build
    cd       build

    ../configure --prefix=/usr
    makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
    makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi

    make install
    install -v -dm755  /usr/share/doc/dejagnu-1.6.3
    install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
}

pck_build_ninja() {
    sed -i '/int Guess/a \
        int   j = 0;\
        char* jobs = getenv( "NINJAJOBS" );\
        if ( jobs != NULL ) j = atoi( jobs );\
        if ( j > 0 ) return j;\
        ' src/ninja.cc

    python3 configure.py --bootstrap --verbose

    install -vm755 ninja /usr/bin/
    install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
    install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja
}

pck_build_pkgconf() {
    tar -xf /sources/meson-1.12.0.tar.gz

    mkdir build
    cd    build

    python3 ../meson-1.12.0/meson.py setup --prefix=/usr --buildtype=release ..
    ninja

    ninja install
    mv /usr/share/doc/pkgconf{,-3.0.5}
    ln -sv pkgconf   /usr/bin/pkg-config
    ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1

ln -sv pkgconf /usr/bin/i686-pc-linux-gnu-pkg-config
ln -sv pkgconf /usr/bin/x86_64-pc-linux-gnu-pkg-config

mkdir -pv /usr/share/pkgconfig/personality.d

cat > /usr/share/pkgconfig/personality.d/i686-pc-linux-gnu.personality << EOF
Triplet: i686-pc-linux-gnu
SysrootDir: /
DefaultSearchPaths: /usr/lib32/pkgconfig:/usr/share/pkgconfig
SystemIncludePaths: /usr/include
SystemLibraryPaths: /usr/lib32
EOF

cat > /usr/share/pkgconfig/personality.d/x86_64-pc-linux-gnu.personality << EOF
Triplet: x86_64-pc-linux-gnu
SysrootDir: /
DefaultSearchPaths: /usr/lib/pkgconfig:/usr/share/pkgconfig
SystemIncludePaths: /usr/include
SystemLibraryPaths: /usr/lib
EOF

}

pck_build_binutils() {
    mkdir -v build
    cd       build

    ../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --enable-new-dtags  \
             --with-system-zlib  \
             --with-lib-path=/usr/lib \
             --enable-default-hash-style=gnu

    make tooldir=/usr

    make tooldir=/usr install

    rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a \
        /usr/share/doc/gprofng/
}

pck_build_gmp() {
    sed -i '/long long t1;/,+1s/()/(...)/' configure

    ./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0
    make
    make html
    make install
    make install-html
    make distclean

    cp -v configfsf.guess config.guess
    cp -v configfsf.sub   config.sub

    CFLAGS="-m32 -O2 -pedantic -fomit-frame-pointer -mtune=generic -march=i686" \
    CXXFLAGS="$CFLAGS"                     \
    ABI="32"                               \
    PKG_CONFIG_PATH="/usr/lib32/pkgconfig" \
    ./configure --prefix=/usr              \
                --host=i686-pc-linux-gnu   \
                --disable-static           \
                --enable-cxx               \
                --libdir=/usr/lib32        \
                --includedir=/usr/include/m32/gmp
    sed -i 's/$(exec_prefix)\/include/$\(includedir\)/' Makefile
    make
    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    cp -Rv DESTDIR/usr/include/m32/* /usr/include/m32/
    rm -rf DESTDIR

}

pck_build_mpfr() {
    ./configure --prefix=/usr        \
                --disable-static     \
                --enable-thread-safe \
                --docdir=/usr/share/doc/mpfr-4.2.2
    make
    make html
    make install
    make install-html

}

pck_build_mpc() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.4.1
    make
    make html
    make install
    make install-html

}

pck_build_isl() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/isl-0.28
    make
    make install
    install -vd /usr/share/doc/isl-0.28
    install -m644 doc/{CodingStyle,manual.pdf,SubmittingPatches,user.pod} \
            /usr/share/doc/isl-0.28

    mkdir -pv /usr/share/gdb/auto-load/usr/lib
    mv -v /usr/lib/libisl*gdb.py /usr/share/gdb/auto-load/usr/lib
}

pck_build_attr() {
    ./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.6.0

    make
    make install

    make distclean

    CC="gcc -m32" ./configure \
        --prefix=/usr         \
        --disable-static      \
        --sysconfdir=/etc     \
        --libdir=/usr/lib32   \
        --host=i686-pc-linux-gnu

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_acl() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/acl-2.4.0
    make
    make install

    make distclean

    CC="gcc -m32" ./configure   \
        --prefix=/usr           \
        --disable-static        \
        --libdir=/usr/lib32     \
        --libexecdir=/usr/lib32 \
        --host=i686-pc-linux-gnu

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_libcap() {
    sed -i '/install -m.*STA/d' libcap/Makefile

    make prefix=/usr lib=lib
    make prefix=/usr lib=lib install
    make distclean

    make CC="gcc -m32 -march=i686"

    make CC="gcc -m32 -march=i686" lib=lib32 prefix=$PWD/DESTDIR/usr -C libcap install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    sed -e "s|^libdir=.*|libdir=/usr/lib32|" -i /usr/lib32/pkgconfig/lib{cap,psx}.pc
    chmod -v 755 /usr/lib32/libcap.so.2.78
    rm -rf DESTDIR

}

pck_build_libxcrypt() {
    sed -i '/strchr/s/const//' lib/crypt-{sm3,gost}-yescrypt.c

    ./configure --prefix=/usr                \
                --enable-hashes=strong,glibc \
                --enable-obsolete-api=no     \
                --disable-static             \
                --disable-failure-tokens

    make
    make install

    make distclean

    CC="gcc -m32"                            \
    ./configure --prefix=/usr                \
                --host=i686-pc-linux-gnu     \
                --libdir=/usr/lib32          \
                --enable-hashes=strong,glibc \
                --enable-obsolete-api=glibc  \
                --disable-static             \
                --disable-failure-tokens

    make

    cp -av .libs/libcrypt.so* /usr/lib32/
    make install-pkgconfigDATA
    ln -svf libxcrypt.pc /usr/lib32/pkgconfig/libcrypt.pc
}

pck_build_shadow() {
    find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
    find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

    sed -e 's:#ENCRYPT_METHOD SHA512:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                      \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                     \
    -i etc/login.defs

    touch /usr/bin/passwd
    ./configure --sysconfdir=/etc   \
                --disable-static    \
                --with-{b,yes}crypt \
                --without-libbsd    \
                --disable-logind    \
                --with-group-name-max-length=32
    
    make
    make exec_prefix=/usr install
    make -C man install-man

    pwconv

    grpconv

    mkdir -p /etc/default
    useradd -D --gid 999

    sed -i '/MAIL/s/yes/no/' /etc/default/useradd
    touch /etc/sub{u,g}id

}

pck_build_gawk() {
    sed -i 's/extras//' Makefile.in

    ./configure --prefix=/usr

    make

    rm -f /usr/bin/gawk-5.4.1
    make install

    rm -f /usr/bin/gawk-5.4.1

    ln -sv gawk.1 /usr/share/man/man1/awk.1

    install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} -t /usr/share/doc/gawk-5.4.1

}

pck_build_gcc() {
    sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64

    sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' \
      -i gcc/config/i386/i386.h

    mkdir -v build
    cd       build

    ../configure --prefix=/usr                \
             LD=ld                        \
             --enable-languages=c,c++     \
             --enable-default-pie         \
             --enable-default-ssp         \
             --enable-host-pie            \
             --enable-multilib            \
             --with-multilib-list=m64,m32 \
             --disable-bootstrap          \
             --disable-fixincludes        \
             --with-system-zlib
    make
    make install

    ln -svr /usr/bin/cpp /usr/lib
    ln -sv gcc.1 /usr/share/man/man1/cc.1
    ln -sfvr $(gcc -print-prog-name=liblto_plugin.so) /usr/lib/bfd-plugins/

    mkdir -pv /usr/share/gdb/auto-load/usr/lib
    mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
}

pck_build_ncurses() {
    ./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib/pkgconfig

    make
    make DESTDIR=$PWD/dest install
    sed -e 's/^#if.*XOPEN.*$/#if 1/' \
        -i dest/usr/include/curses.h
    cp --remove-destination -av dest/* /

    for lib in ncurses form panel menu ; do
        ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
        ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
    done

    ln -sfv libncursesw.so /usr/lib/libcurses.so

    cp -v -R doc -T /usr/share/doc/ncurses-6.6

    make distclean

    CC="gcc -m32" CXX="g++ -m32"         \
    ./configure --prefix=/usr            \
                --host=i686-pc-linux-gnu \
                --libdir=/usr/lib32      \
                --mandir=/usr/share/man  \
                --with-shared            \
                --without-debug          \
                --without-normal         \
                --with-cxx-shared        \
                --enable-pc-files        \
                --with-pkg-config-libdir=/usr/lib32/pkgconfig

    make

    make DESTDIR=$PWD/DESTDIR install
    mkdir -p DESTDIR/usr/lib32/pkgconfig
    for lib in ncurses form panel menu ; do
        rm -vf                    DESTDIR/usr/lib32/lib${lib}.so
        echo "INPUT(-l${lib}w)" > DESTDIR/usr/lib32/lib${lib}.so
        ln -svf ${lib}w.pc        DESTDIR/usr/lib32/pkgconfig/$lib.pc
    done
    rm -vf                     DESTDIR/usr/lib32/libcursesw.so
    echo "INPUT(-lncursesw)" > DESTDIR/usr/lib32/libcursesw.so
    ln -sfv libncurses.so      DESTDIR/usr/lib32/libcurses.so
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_sed() {
    ./configure --prefix=/usr

    make
    make html

    make install
    install -vDm644 doc/sed.html -t /usr/share/doc/sed-4.10
}

pck_build_psmisc() {
    ./configure --prefix=/usr
    make
    make install
}

pck_build_gettext() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-1.0
    make
    make install
    chmod -v 0755 /usr/lib/preloadable_libintl.so
}

pck_build_bison() {
    ./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
    make
    make install
}

pck_build_grep() {
    sed -i "s/echo/#echo/" src/egrep.sh

    ./configure --prefix=/usr
    make
    make install

}

pck_build_bash() {
    ./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.3

    make
    make install

}

pck_build_libtool() {
    ./configure --prefix=/usr
    make
    make install
    rm -fv /usr/lib/libltdl.a
    make distclean
    CC="gcc -m32" ./configure    \
        --host=i686-pc-linux-gnu \
        --prefix=/usr            \
        --libdir=/usr/lib32

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_gdbm() {
    ./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat
    make
    make install
    make distclean

    CC="gcc -m32" CXX="g++ -m32"         \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static         \
                --enable-libgdbm-compat

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32/
    rm -rf DESTDIR

}

pck_build_gperf() {
    ./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.3
    make
    make install
}

pck_build_expat() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.8.3
    make
    make install

    install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.8.3

    sed -e "/^am__append_1/ s/doc//" -i Makefile
    make clean

    CC="gcc -m32"                        \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_inetutils() {
    sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c

    ./configure --prefix=/usr        \
                --bindir=/usr/bin    \
                --localstatedir=/var \
                --disable-logger     \
                --disable-whois      \
                --disable-rcp        \
                --disable-rexec      \
                --disable-rlogin     \
                --disable-rsh        \
                --disable-servers

    make
    make install

    mv -v /usr/{,s}bin/ifconfig
}

pck_build_less() {
    ./configure --prefix=/usr --sysconfdir=/etc
    make
    make install
}

pck_build_perl() {
    export BUILD_ZLIB=False
    export BUILD_BZIP2=0

    sh Configure -des                                          \
                -D prefix=/usr                                \
                -D vendorprefix=/usr                          \
                -D privlib=/usr/lib/perl5/5.44/core_perl      \
                -D archlib=/usr/lib/perl5/5.44/core_perl      \
                -D sitelib=/usr/lib/perl5/5.44/site_perl      \
                -D sitearch=/usr/lib/perl5/5.44/site_perl     \
                -D vendorlib=/usr/lib/perl5/5.44/vendor_perl  \
                -D vendorarch=/usr/lib/perl5/5.44/vendor_perl \
                -D man1dir=/usr/share/man/man1                \
                -D man3dir=/usr/share/man/man3                \
                -D pager="/usr/bin/less -isR"                 \
                -D useshrplib                                 \
                -D usethreads

    make
    make install

}

pck_build_autoconf() {
    ./configure --prefix=/usr
    make
    make install
}

pck_build_automake() {
    ./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.18.1
    make
    make install

}

pck_build_openssl() {
    ./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
    make
    make INSTALL_LIBS= MANSUFFIX=ssl install

    mv -v /usr/share/doc/openssl /usr/share/doc/openssl-4.0.1

    cp -vfr doc/* /usr/share/doc/openssl-4.0.1

    make distclean
    ./config --prefix=/usr         \
            --openssldir=/etc/ssl \
            --libdir=lib32        \
            shared                \
            zlib-dynamic          \
            no-docs               \
            linux-x86

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_libelf() {
    ./configure --prefix=/usr        \
            --disable-debuginfod \
            --enable-libdebuginfod=dummy

    make -C lib
    make -C libelf

    make -C libelf install
    install -vm644 config/libelf.pc /usr/lib/pkgconfig
    rm /usr/lib/libelf.a

    make distclean

    CC="gcc -m32" CXX="g++ -m32"         \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-debuginfod     \
                --enable-libdebuginfod=dummy

    make -C lib
    make -C libelf

    make DESTDIR=$PWD/DESTDIR -C libelf install
    install -vDm644 config/libelf.pc DESTDIR/usr/lib32/pkgconfig/libelf.pc
    rm -vf DESTDIR/usr/lib32/libelf.a
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_libffi() {
    ./configure --prefix=/usr    \
            --disable-static \
            --with-gcc-arch=native
    make
    make install

    make distclean

    CC="gcc -m32" CXX="g++ -m32"         \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static         \
                --with-gcc-arch=i686

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_sqlite() {
    python3 -m zipfile -e /sources/sqlite-doc-3530400.zip .

    ./configure --prefix=/usr     \
                --disable-static  \
                --enable-fts{4,5} \
                CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 \
                        -D SQLITE_ENABLE_UNLOCK_NOTIFY=1   \
                        -D SQLITE_ENABLE_DBSTAT_VTAB=1     \
                        -D SQLITE_SECURE_DELETE=1"

    make LDFLAGS.rpath=""

    make install

    cp -v -R sqlite-doc-3530400 -T /usr/share/doc/sqlite-3.53.4

    make distclean

    CC="gcc -m32" CXX="g++ -m32"         \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static         \
                --enable-fts{4,5}        \
                CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 \
                        -D SQLITE_ENABLE_UNLOCK_NOTIFY=1   \
                        -D SQLITE_ENABLE_DBSTAT_VTAB=1     \
                        -D SQLITE_SECURE_DELETE=1"

    make LDFLAGS.rpath=""

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_mpdecimal() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpdecimal-4.0.1

    make 
    make install
}

pck_build_python() {
    patch -Np1 -i /sources/Python-3.14.7-openssl_4-1.patch

    ./configure --prefix=/usr          \
            --enable-shared        \
            --with-system-expat    \
            --enable-optimizations \
            --without-static-libpython

    make
    make install

cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF


}

pck_build_flitcore() {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
    pip3 install --no-index --find-links dist flit_core
}

pck_build_packaging() {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

    pip3 install --no-index --find-links dist packaging
}

pck_build_wheel() {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

    pip3 install --no-index --find-links dist wheel
}

pck_build_setuptools() {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

    pip3 install --no-index --find-links dist setuptools
}

pck_build_meson() {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

    pip3 install --no-index --find-links dist meson
    install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
    install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

mkdir -pv /usr/share/meson/cross
mkdir -pv /usr/share/meson/native
for i in {cross/lib32,native/x86}; do
cat > /usr/share/meson/$i << "EOF"
[binaries]
c = ['gcc', '-m32']
cpp = ['g++', '-m32']
rust = ['rustc', '--target', 'i686-unknown-linux-gnu']
pkg-config = 'i686-pc-linux-gnu-pkg-config'
ar = '/usr/bin/ar'
strip = '/usr/bin/strip'
cups-config = 'cups-config'
llvm-config = 'llvm-config'
exe_wrapper = ''

[built-in options]
libdir = 'lib32'

[properties]
sizeof_void* = 4
sizeof_long = 4

[host_machine]
system = 'linux'
subsystem = 'linux'
kernel = 'linux'
cpu_family = 'x86'
cpu = 'i686'
endian = 'little'
EOF
done
}

pck_build_kmod() {
    mkdir -p build
    cd       build

    meson setup --prefix=/usr ..    \
                --buildtype=release \
                -D manpages=false
    ninja
    ninja install

    rm -rf *

    meson setup --prefix=/usr       \
                --buildtype=release \
                --cross-file=lib32  \
                -D manpages=false   \
                ..

    ninja

    DESTDIR=$PWD/DESTDIR ninja install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_coreutils() {
    patch -Np1 -i /sources/coreutils-9.11-i18n-1.patch

    autoreconf -fv
    automake -af
    FORCE_UNSAFE_CONFIGURE=1 ./configure \
                --prefix=/usr

    make
    make install

    mv -v /usr/bin/chroot /usr/sbin
    mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
                
}

pck_build_diffutils() {
    ./configure --prefix=/usr
    make
    make install

}

pck_build_findutils() {
    ./configure --prefix=/usr --localstatedir=/var/lib/locate
    make
    make install

}

pck_build_groff() {
    PAGE=letter ./configure --prefix=/usr

    make -j1
    make install
}

pck_build_grub() {
    sed 's/--image-base/--nonexist-linker-option/' -i configure

    ./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-efiemu  \
            --disable-werror

    make
    make install

    make clean

    ./configure --prefix=/usr       \
            --sysconfdir=/etc   \
            --target=x86_64     \
            --with-platform=efi \
            --disable-efiemu    \
            --disable-werror

    make
    make install

    make clean

    ./configure --prefix=/usr       \
                --sysconfdir=/etc   \
                --target=i386       \
                --with-platform=efi \
                --disable-efiemu    \
                --disable-werror

    make 
    make install
}

pck_build_gzip() {
    ./configure --prefix=/usr
    make
    make install
}

pck_build_iproute2() {
    sed -i /ARPD/d Makefile
    rm -fv man/man8/arpd.8

    make NETNS_RUN_DIR=/run/netns

    make SBINDIR=/usr/sbin install

    install -vDm644 COPYING README* -t /usr/share/doc/iproute2-7.1.0
}

pck_build_kbd() {
    patch -Np1 -i /sources/kbd-2.10.0-backspace-1.patch

    sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
    sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

    ./configure --prefix=/usr --disable-vlock
    make
    make install
    cp -R -v docs/doc -T /usr/share/doc/kbd-2.10.0
}

pck_build_libpipeline() {
    ./configure --prefix=/usr
    make
    make install
}

pck_build_make() {
    ./configure --prefix=/usr
    make
    make install
}

pck_build_patch() {
    ./configure --prefix=/usr
    make
    make install

}

pck_build_tar() {
    patch -Np1 -i /sources/tar-1.35-acl_fix-1.patch

    FORCE_UNSAFE_CONFIGURE=1  \
    ./configure --prefix=/usr
    make
    make install
    make -C doc install-html docdir=/usr/share/doc/tar-1.35
}

pck_build_texinfo() {
    ./configure --prefix=/usr
    make
    make install
    make TEXMF=/usr/share/texmf install-tex

}

pck_build_vim() {
    echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
    ./configure --prefix=/usr
    make
    make install
    ln -sv vim /usr/bin/vi

    for L in  /usr/share/man/{,*/}man1/vim.1; do
        ln -sv vim.1 $(dirname $L)/vi.1
    done

    ln -sv ../vim/vim92/doc /usr/share/doc/vim-9.2.1025
}

pck_build_markupsafe() {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
    pip3 install --no-index --find-links dist Markupsafe
}

pck_build_jinja2() {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

    pip3 install --no-index --find-links dist Jinja2
}

pck_build_systemd() {
    sed -e 's/GROUP="render"/GROUP="video"/' \
    -e 's/GROUP="sgx", //'               \
    -i rules.d/50-udev-default.rules.in

    mkdir -p build
    cd       build

    meson setup ..                \
        --prefix=/usr           \
        --buildtype=release     \
        -D default-dnssec=no    \
        -D firstboot=false      \
        -D install-tests=false  \
        -D ldconfig=false       \
        -D sysusers=false       \
        -D rpmmacrosdir=no      \
        -D homed=disabled       \
        -D man=disabled         \
        -D mode=release         \
        -D pamconfdir=no        \
        -D dev-kvm-mode=0660    \
        -D nobody-group=nogroup \
        -D sysupdate=disabled   \
        -D ukify=disabled       \
        -D docdir=/usr/share/doc/systemd-261.2

    ninja
    ninja install

    tar -xf /sources/systemd-man-pages-261.2.tar.xz \
        --no-same-owner --strip-components=1     \
        -C /usr/share/man

    systemd-machine-id-setup
    systemctl preset-all

    rm -rf *

    LANG=en_US.UTF-8                    \
    meson setup --prefix=/usr           \
                --buildtype=release     \
                --cross-file=lib32      \
                -D default-dnssec=no    \
                -D firstboot=false      \
                -D install-tests=false  \
                -D ldconfig=false       \
                -D sysusers=false       \
                -D rpmmacrosdir=no      \
                -D homed=disabled       \
                -D userdb=false         \
                -D man=disabled         \
                -D mode=release         \
                -D nobody-group=nogroup \
                -D sysupdate=disabled   \
                -D ukify=disabled       \
                ..
    
    LANG=en_US.UTF-8 ninja

    LANG=en_US.UTF-8 DESTDIR=$PWD/DESTDIR ninja install
    cp -av DESTDIR/usr/lib32/libsystemd.so* /usr/lib32/
    cp -av DESTDIR/usr/lib32/libudev.so* /usr/lib32/
    cp -v  DESTDIR/usr/lib32/pkgconfig/* /usr/lib32/pkgconfig/
    rm -rf DESTDIR
}

pck_build_dbus() {
    mkdir build
    cd    build

    meson setup --prefix=/usr --buildtype=release --wrap-mode=nofallback ..

    ninja
    ninja install

    ln -sfv /etc/machine-id /var/lib/dbus

    rm -rf *

    meson setup --prefix=/usr          \
                --buildtype=release    \
                --cross-file=lib32     \
                --wrap-mode=nofallback \
                ..

    ninja

    DESTDIR=$(pwd)/destdir ninja install
    mkdir -pv /usr/lib32/pkgconfig
    cp -av $(pwd)/destdir/usr/lib32/libdbus-1.so* /usr/lib32/
    cp -av $(pwd)/destdir/usr/lib32/dbus-1.0 /usr/lib32/
    cp -v  $(pwd)/destdir/usr/lib32/pkgconfig/dbus-1.pc /usr/lib32/pkgconfig/
}

pck_build_mandb() {
    ./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.13.1 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap

    make
    make install

}

pck_build_procpsng() {
    ./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.7 \
            --disable-static                        \
            --disable-kill                          \
            --enable-watch8bit                      \
            --with-systemd

    make
    make install
}

pck_build_utillinux() {
    ./configure --bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-liblastlog2 \
            --disable-static      \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.42.2

    make

    make install

    make distclean

    mv /usr/bin/ncursesw6-config{,.tmp}

    CC="gcc -m32"                        \
    ./configure --host=i686-pc-linux-gnu \
                --libdir=/usr/lib32      \
                --runstatedir=/run       \
                --sbindir=/usr/sbin      \
                --disable-chfn-chsh      \
                --disable-login          \
                --disable-nologin        \
                --disable-su             \
                --disable-setpriv        \
                --disable-runuser        \
                --disable-pylibmount     \
                --disable-liblastlog2    \
                --disable-static         \
                --without-python         \
                ADJTIME_PATH=/var/lib/hwclock/adjtime

    mv /usr/bin/ncursesw6-config{.tmp,}

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_e2fsprogs() {
    mkdir -v build
    cd       build

    ../configure --prefix=/usr       \
                --sysconfdir=/etc   \
                --enable-elf-shlibs \
                --disable-libblkid  \
                --disable-libuuid   \
                --disable-uuidd     \
                --disable-fsck

    make
    make install

    rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

    gunzip -v /usr/share/info/libext2fs.info.gz
    install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

    makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
    install -v -m644 doc/com_err.info /usr/share/info
    install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

    sed 's/metadata_csum_seed,//' -i /etc/mke2fs.conf
}

pck_build_cleanup() {
    echo "Cleaning up..."
    rm -rf /tmp/{*,.*}
    find /usr/lib{,32,exec} -name \*.la -delete || true
    find /usr -depth -name x86_64-lfs-linux-gnu\* | xargs rm -rf || true
}

pck_build_initconfig() {
    systemctl disable systemd-networkd-wait-online
    ln -s /dev/null /etc/systemd/network/99-default.link

cat > /etc/systemd/network/10-eth-dhcp.network << "EOF"
[Match]
Name=eth0

[Network]
DHCP=ipv4

[DHCPv4]
UseDomains=true
EOF

cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

nameserver 8.8.8.8

# End /etc/resolv.conf
EOF

    echo "plx" > /etc/hostname

cat > /etc/hosts << "EOF"
# Begin /etc/hosts

::1       ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters
127.0.0.1   localhost

# End /etc/hosts
EOF

cat > /etc/adjtime << "EOF"
0.0 0 0.0
0
LOCAL
EOF

cat > /etc/locale.conf << "EOF"
LANG=en_US.UTF-8
EOF

cat > /etc/profile << "EOF"
# Begin /etc/profile

for i in $(locale); do
  unset ${i%=*}
done

if [[ "$TERM" = linux ]]; then
  export LANG=C.UTF-8
else
  source /etc/locale.conf

  for i in $(locale); do
    key=${i%=*}
    if [[ -v $key ]]; then
      export $key
    fi
  done
fi

# End /etc/profile
EOF

cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8-bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# uncomment for history search mode with up/down
# "\e[A": history-search-backward
# "\e[B": history-search-forward

# End /etc/inputrc
EOF

cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF


cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

/dev/nvme2n1p6     /            ext2    defaults            1     1

# End /etc/fstab
EOF

}

pck_build_kernel() {
    cd ..
    mkdir -p /usr/src/
    rm -rf /usr/src/linux

    mv linux-7.1.8 /usr/src/linux

    cd /usr/src/linux
    make mrproper
    cp /sources/.config .
    #make menuconfig
    make
    make modules_install

    cp -iv arch/x86/boot/bzImage /boot/vmlinuz-7.1.8
    cp -iv System.map /boot/System.map-7.1.8
    cp -iv .config /boot/config-7.1.8
    cp -r Documentation -T /usr/share/doc/linux-7.1.8

install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

}

pck_build_post_core() {
echo "MLFS #c67e8" > /etc/lfs-release
cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="MLFS #c67e8"
DISTRIB_CODENAME="<your name here>"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

cat > /etc/os-release << "EOF"
NAME="Linux From Scratch"
VERSION="MLFS #c67e8"
ID=lfs
PRETTY_NAME="Multilib Linux From Scratch #c67e8"
VERSION_CODENAME="<your name here>"
HOME_URL="https://www.linuxfromscratch.org/lfs/"
RELEASE_TYPE="development"
EOF

passwd root

}

pck_build_nvidia_driver() {
    cd /tmp/build
    
    sh /sources/NVIDIA-Linux-x86_64-610.57.04.run -z \
        -j $(nproc)   \
        -k `uname -r` \
        --no-peermem  \
        --override-file-type-destination=OPENCL_WRAPPER_LIB:/tmp/nvidia \
        --override-file-type-destination=OPENCL_WRAPPER_SYMLINK:/tmp/nvidia
}


pck_build_bashstartup() {
    cat > /etc/profile << "EOF"
# Begin /etc/profile
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>
# modifications by Dagmar d'Surreal <rivyqntzne@pbzpnfg.arg>

# System wide environment variables and startup programs.

# System wide aliases and functions should go in /etc/bashrc.  Personal
# environment variables and startup programs should go into
# ~/.bash_profile.  Personal aliases and functions should go into
# ~/.bashrc.

# Functions to help us manage paths.  Second argument is the name of the
# path variable to be modified (default: PATH)
pathremove () {
        local IFS=':'
        local NEWPATH
        local DIR
        local PATHVARIABLE=${2:-PATH}
        for DIR in ${!PATHVARIABLE} ; do
                if [ "$DIR" != "$1" ] ; then
                  NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
                fi
        done
        export $PATHVARIABLE="$NEWPATH"
}

pathprepend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
}

pathappend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}$1"
}

export -f pathremove pathprepend pathappend

# Set the initial path
export PATH=/usr/bin

# Attempt to provide backward compatibility with LFS earlier than 11
if [ ! -L /bin ]; then
        pathappend /bin
fi

if [ $EUID -eq 0 ] ; then
        pathappend /usr/sbin
        if [ ! -L /sbin ]; then
                pathappend /sbin
        fi
        unset HISTFILE
fi

# Set up some environment variables.
export HISTSIZE=1000
export HISTIGNORE="&:[bf]g:exit"
export XDG_DATA_DIRS=${XDG_DATA_DIRS:-/usr/share}
export XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-/etc/xdg}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/tmp/xdg-$USER}

for script in /etc/profile.d/*.sh ; do
        if [ -r $script ] ; then
                . $script
        fi
done

unset script

# End /etc/profile
EOF

install --directory --mode=0755 --owner=root --group=root /etc/profile.d

cat > /etc/profile.d/extrapaths.sh << "EOF"
if [ -d /usr/local/lib/pkgconfig ] ; then
        pathappend /usr/local/lib/pkgconfig PKG_CONFIG_PATH
fi
if [ -d /usr/local/bin ]; then
        pathprepend /usr/local/bin
fi
if [ -d /usr/local/sbin -a $EUID -eq 0 ]; then
        pathprepend /usr/local/sbin
fi

if [ -d /usr/local/share ]; then
        pathprepend /usr/local/share XDG_DATA_DIRS
fi

# Set some defaults before other applications add to these paths.
pathappend /usr/share/info INFOPATH
EOF

cat > /etc/profile.d/readline.sh << "EOF"
# Set up the INPUTRC environment variable.
if [ -z "$INPUTRC" -a ! -f "$HOME/.inputrc" ] ; then
        INPUTRC=/etc/inputrc
fi
export INPUTRC
EOF

cat > /etc/profile.d/umask.sh << "EOF"
# By default, the umask should be set.
if [ "$(id -gn)" = "$(id -un)" -a $EUID -gt 99 ] ; then
  umask 002
else
  umask 022
fi
EOF

cat > /etc/profile.d/i18n.sh << "EOF"
# Set up i18n variables
for i in $(locale); do
  unset ${i%=*}
done

if [[ "$TERM" = linux ]]; then
  export LANG=C.UTF-8
else
  source /etc/locale.conf

  for i in $(locale); do
    key=${i%=*}
    if [[ -v $key ]]; then
      export $key
    fi
  done
fi
EOF

cat > /etc/profile.d/dircolors.sh << "EOF"
# Setup for /bin/ls and /bin/grep to support color
if [ -f "/etc/dircolors" ] ; then
        eval $(dircolors -b /etc/dircolors)
fi

if [ -f "$HOME/.dircolors" ] ; then
        eval $(dircolors -b $HOME/.dircolors)
fi
EOF

cat > /etc/profile.d/aliases.sh << "EOF"
# Make ls, grep, and diff use --color=auto
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
EOF

cat > /root/.bash_profile << "EOF"
echo "LOADING PROFILE"
source /etc/profile
EOF

}

pck_build_icu() {
    cd source                                    
    ./configure --prefix=/usr
    make
    make install
    make clean 
    CC="gcc -m32" CXX="g++ -m32"         \
    PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
    ./configure --prefix=/usr --libdir=/usr/lib32 --host=i686-pc-linux-gnu 
    make
    make DESTDIR=$PWD/DESTDIR install     
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig

}

pck_build_libxml2() {
    pkgconf --list-all

    echo "NEXT"

    #/usr/bin/i686-pc-linux-gnu-pkg-config --list-all

    sed -i "/'git'/,+3d" meson.build

    mkdir build &&
    cd    build &&

    meson setup --prefix=/usr       \
                --buildtype=release \
                -D history=enabled  \
                -D icu=enabled 
    ninja
    ninja install 
    sed 's/--static/--shared/' -i /usr/bin/xml2-config

    rm -rf * 
    meson setup --prefix=/usr            \
                --buildtype=release      \
                --cross-file=lib32       \
                -D history=enabled       \
                -D icu=enabled 
    ninja


    DESTDIR=$PWD/DESTDIR ninja install    
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_nghttp2() {
    ./configure --prefix=/usr     \
            --disable-static  \
            --enable-lib-only \
            --docdir=/usr/share/doc/nghttp2-1.70.0 &&
    make
    make install

    make distclean 
    CC="gcc -m32" CXX="g++ -m32"         \
    PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static         \
                --enable-lib-only       
    make


    make DESTDIR=$PWD/DESTDIR install    
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_libtasn1() {
    ./configure --prefix=/usr --disable-static 
    make
    make install

    make distclean 
    CC="gcc -m32" CXX="g++ -m32"         \
    PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static 

    make

    make DESTDIR=$PWD/DESTDIR install     
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig

}

pck_build_nspr() {
    cd nspr 

    sed -i '/^RELEASE/s|^|#|' pr/src/misc/Makefile.in 
    sed -i 's|$(LIBRARY) ||'  config/rules.mk         

    ./configure --prefix=/usr   \
                --with-mozilla  \
                --with-pthreads \
                --enable-64bit 

    make 
    make install

    make distclean 
    CC="gcc -m32" CXX="g++ -m32"   \
    PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --with-mozilla           \
                --with-pthreads          \
                --disable-64bit 

    make

    make DESTDIR=$PWD/DESTDIR install     
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_nss() {
    patch -Np1 -i /sources/nss-standalone-1.patch 

    cd nss 

    make BUILD_OPT=1                        \
        NSPR_INCLUDE_DIR=/usr/include/nspr \
        USE_SYSTEM_ZLIB=1                  \
        ZLIB_LIBS=-lz                      \
        NSS_ENABLE_WERROR=0                \
        USE_64=1                           \
        NSS_USE_SYSTEM_SQLITE=1

    cd ../dist 

    install -vDm755 Linux*/lib/*.so  -t /usr/lib/        
    install -vDm644 Linux*/lib/*.chk -t /usr/lib/        

    install -vdm755                     /usr/include/nss 
    cp -v -RL {public,private}/nss/*    /usr/include/nss 

    install -vDm755 \
    Linux*/bin/{certutil,nss-config,pk12util} \
                                    -t /usr/bin/        

    install -vDm644 Linux*/lib/pkgconfig/nss.pc -t /usr/lib/pkgconfig/

    cd ../nss                                         
    find -name "Linux*.OBJ" -type d -exec rm -rf {} + 
    rm -rf ../dist                                    

    CC="gcc -m32" CXX="g++ -m32"            \
    make BUILD_OPT=1                        \
        NSPR_INCLUDE_DIR=/usr/include/nspr \
        USE_SYSTEM_ZLIB=1                  \
        ZLIB_LIBS=-lz                      \
        NSS_ENABLE_WERROR=0                \
        NSS_USE_SYSTEM_SQLITE=1

    cd ../dist 

    install -vDm755 Linux*/lib/*.so  -t /usr/lib32/           
    install -vDm644 Linux*/lib/*.chk -t /usr/lib32/           
    sed -i 's/lib/lib32/g'                                     \
                    Linux*/lib/pkgconfig/nss.pc               
    install -vDm644                                            \
                    Linux*/lib/pkgconfig/nss.pc                \
                                    -t /usr/lib32/pkgconfig/ 
    ldconfig
}


pck_build_p11kit() {
    sed '20,$ d' -i trust/trust-extract-compat &&

    cat >> trust/trust-extract-compat << "EOF"
# Copy existing anchor modifications to /etc/ssl/local
/usr/libexec/make-ca/copy-trust-modifications

# Update trust stores
/usr/sbin/make-ca -r
EOF

    mkdir p11-build 
    cd    p11-build 

    meson setup --prefix=/usr                   \
                --buildtype=release             \
                -D test=false                   \
                -D trust_paths=/etc/pki/anchors \
                .. 
    ninja


    ninja install 
    ln -sfv /usr/libexec/p11-kit/trust-extract-compat \
            /usr/bin/update-ca-certificates


    rm -rf * 
    meson setup --prefix=/usr                   \
                --buildtype=release             \
                --cross-file=lib32              \
                -D test=false                   \
                -D trust_paths=/etc/pki/anchors \
                .. 
    ninja

    DESTDIR=$PWD/DESTDIR ninja install    
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig

    for lib in lib{,32}; do
    ln -sfv ./pkcs11/p11-kit-trust.so \
            /usr/"$lib"/libnssckbi.so
    done
}

pck_build_makeca() {
    cat >> make-ca << "EOF"
ln -svf /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
EOF

    sed '/mktemp/s/-t //' -i make-ca

    make install 
    install -vdm755 /etc/ssl/local

    /usr/sbin/make-ca -g
}

pck_build_libunistring() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/libunistring-1.4.2 &&

    make
    make install

    make distclean 
    CC="gcc -m32" CXX="g++ -m32"         \
    PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static 

    make

    make DESTDIR=$PWD/DESTDIR install     
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_libidn2() {
    ./configure --prefix=/usr --disable-static 
    make

    make install
    make distclean &&
    CC="gcc -m32" CXX="g++ -m32"         \
    PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static 

    make

    make DESTDIR=$PWD/DESTDIR install     
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_libpsl() {
    mkdir build 
    cd    build 

    meson setup --prefix=/usr --buildtype=release 

    ninja
    ninja install

    rm -rf * 
    meson setup --prefix=/usr            \
                --buildtype=release      \
                --cross-file=lib32       \
                .. 
    ninja

    DESTDIR=$PWD/DESTDIR ninja install    
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_curl() {
    mkdir build 
    cd    build 

    ../configure --prefix=/usr                 \
                --disable-static              \
                --with-openssl                \
                --with-ca-path=/etc/ssl/certs 

    make

    make install 

    rm -rf docs/examples/.deps 

    find docs \( -name Makefile\* -o  \
                -name \*.1       -o  \
                -name \*.3       -o  \
                -name CMakeLists.txt \) -delete 

    cp -v -R docs -T /usr/share/doc/curl-8.21.0


    rm -rf * 
    CC="gcc -m32" CXX="g++ -m32"           \
    PKGCONFIG=i686-pc-linux-gnu-pkg-config \
    ../configure --prefix=/usr             \
                --libdir=/usr/lib32       \
                --host=i686-pc-linux-gnu  \
                --disable-static          \
                --with-openssl            \
                --without-brotli          \
                --with-ca-path=/etc/ssl/certs 

    make

    make DESTDIR=$PWD/DESTDIR install     
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_wget() {
    NEW_LINE='#if !defined OPENSSL_NO_SSL3_METHOD '
    NEW_LINE+='&& OPENSSL_VERSION_NUMBER < 0x40000000L'

    sed -i "/SSL3/c $NEW_LINE" src/openssl.c

    unset NEW_LINE

    ./configure --prefix=/usr      \
                --sysconfdir=/etc  \
                --with-ssl=openssl 

    make

    make install
}


pck_build_manpages() {
    rm -v man3/crypt*
    make -R GIT=false prefix=/usr install
}

pck_build_ianaetc() {
    cp -v services protocols /etc
}

pck_build_glibc() {
    patch -Np1 -i /sources/glibc-fhs-1.patch
    patch -Np1 -i /sources/glibc-2.44-upstream_fixes-1.patch

    mkdir build
    cd build

    ../configure --prefix=/usr                   \
             --disable-werror                \
             --disable-nscd                  \
             libc_cv_slibdir=/usr/lib        \
             --enable-stack-protector=strong \
             --enable-kernel=5.10

    make
    touch /etc/ld.so.conf
    sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

    make install
    sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd

    localedef -i C -f UTF-8 C.UTF-8
    localedef -i en_US -f ISO-8859-1 en_US
    localedef -i en_US -f UTF-8 en_US.UTF-8

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files systemd
group: files systemd
shadow: files systemd

hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

    tar -xf /sources/tzdata2026c.tar.gz

    ZONEINFO=/usr/share/zoneinfo
    mkdir -pv $ZONEINFO/{posix,right}

    for tz in etcetera southamerica northamerica europe africa antarctica  \
            asia australasia backward; do
        zic -L /dev/null   -d $ZONEINFO       ${tz}
        zic -L /dev/null   -d $ZONEINFO/posix ${tz}
        zic -L leapseconds -d $ZONEINFO/right ${tz}
    done

    cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
    zic -d $ZONEINFO -p America/New_York
    unset ZONEINFO tz

    ln -sfv /usr/share/zoneinfo/America/Chicago /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF

    mkdir -pv /etc/ld.so.conf.d

    #build 32 bit
    rm -rf ./*
    find .. -name "*.a" -delete

    CC="gcc -m32" CXX="g++ -m32"             \
    ../configure                             \
        --prefix=/usr                      \
        --host=i686-pc-linux-gnu           \
        --build=$(../scripts/config.guess) \
        --libdir=/usr/lib32                \
        --libexecdir=/usr/lib32            \
        --disable-werror                   \
        --disable-nscd                     \
        libc_cv_slibdir=/usr/lib32         \
        --enable-stack-protector=strong    \
        --enable-kernel=5.10

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -a DESTDIR/usr/lib32/* /usr/lib32/
    install -vm644 DESTDIR/usr/include/gnu/{lib-names,stubs}-32.h \
                /usr/include/gnu/
    
    echo "/usr/lib32" > /etc/ld.so.conf.d/lib32.conf

}

pck_build_zlib() {
    ./configure --prefix=/usr
    make
    make install
    make distclean
    CFLAGS+=" -m32" CXXFLAGS+=" -m32" \
    ./configure --prefix=/usr --libdir=/usr/lib32
    make
    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_bzip2() {
    patch -Np1 -i /sources/bzip2-1.0.8-install_docs-1.patch
    sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile

    sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

    make -f Makefile-libbz2_so
    make clean
    make

    make PREFIX=/usr install

    cp -av libbz2.so.* /usr/lib
    ln -sfv libbz2.so.1.0.8 /usr/lib/libbz2.so

    ln -sfv libbz2.so.1.0.8 /usr/lib/libbz2.so.1

    cp -v bzip2-shared /usr/bin/bzip2
    for i in /usr/bin/{bzcat,bunzip2}; do
    ln -sfv bzip2 $i
    done

    make clean
    make -f Makefile-libbz2_so clean

    sed -e "s/^CC=.*/CC=gcc -m32/" -i Makefile{,-libbz2_so}
    make -f Makefile-libbz2_so

    install -Dm755 libbz2.so.1.0.8 /usr/lib32/libbz2.so.1.0.8
    ln -svf libbz2.so.1.0.8 /usr/lib32/libbz2.so
    ln -svf libbz2.so.1.0.8 /usr/lib32/libbz2.so.1
    ln -svf libbz2.so.1.0.8 /usr/lib32/libbz2.so.1.0

}

pck_build_xz() {
    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/xz-5.8.3


    make

    make install

    make distclean

    CC="gcc -m32" ./configure         \
        --host=i686-pc-linux-gnu      \
        --prefix=/usr                 \
        --libdir=/usr/lib32           \
        --disable-static

    make
    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_lz4() {
    make BUILD_STATIC=no PREFIX=/usr

    make BUILD_STATIC=no PREFIX=/usr install

    make clean

    CC="gcc -m32" make BUILD_STATIC=no -C lib

    make BUILD_STATIC=no    \
        PREFIX=/usr        \
        LIBDIR=/usr/lib32  \
        DESTDIR=$(pwd)/m32 \
        -C lib install
    cp -vR m32/usr/lib32/* /usr/lib32/

}

pck_build_zstd() {
    make prefix=/usr

    make prefix=/usr install

    rm -v /usr/lib/libzstd.a

    make clean

    CC="gcc -m32" make prefix=/usr

    make prefix=/usr DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib/* /usr/lib32/
    sed -e "/^libdir/s/lib$/lib32/" -i /usr/lib32/pkgconfig/libzstd.pc
    rm -rf DESTDIR

}

pck_build_file() {
    ./configure --prefix=/usr

    make

    make install

    make distclean

    CC="gcc -m32" ./configure \
        --prefix=/usr         \
        --libdir=/usr/lib32   \
        --host=i686-pc-linux-gnu

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR

}

pck_build_readline() {
    sed -i '/MV.*old/d' Makefile.in
    sed -i '/{OLDSUFF}/c:' support/shlib-install

    sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf

    sed -e '270a\
        else\
        chars_avail = 1;'      \
        -e '288i\   result = -1;' \
        -i.orig input.c

    ./configure --prefix=/usr    \
                --disable-static \
                --with-curses    \
                --docdir=/usr/share/doc/readline-8.3

    make SHLIB_LIBS="-lncursesw"

    make install

    install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.3

    make distclean

    CC="gcc -m32" ./configure         \
        --host=i686-pc-linux-gnu      \
        --prefix=/usr                 \
        --libdir=/usr/lib32           \
        --disable-static              \
        --with-curses

    make SHLIB_LIBS="-lncursesw"

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_pcre2() {
    ./configure --prefix=/usr                       \
            --docdir=/usr/share/doc/pcre2-10.47 \
            --enable-unicode                    \
            --enable-jit                        \
            --enable-pcre2-16                   \
            --enable-pcre2-32                   \
            --enable-pcre2grep-libz             \
            --enable-pcre2grep-libbz2           \
            --enable-pcre2test-libreadline      \
            --disable-static

    make
    make install

    make distclean

    CC="gcc -m32" CXX="g++ -m32"               \
    ./configure --prefix=/usr                  \
                --libdir=/usr/lib32            \
                --host=i686-pc-linux-gnu       \
                --enable-unicode               \
                --enable-jit                   \
                --enable-pcre2-16              \
                --enable-pcre2-32              \
                --enable-pcre2grep-libz        \
                --enable-pcre2grep-libbz2      \
                --enable-pcre2test-libreadline \
                --disable-static

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_m4() {
    ./configure --prefix=/usr
    make
    make install

}

pck_build_bc() {
    CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r
    make
    make install
}

pck_build_flex() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/flex-2.6.4

    make

    make install

    ln -sv flex   /usr/bin/lex
    ln -sv flex.1 /usr/share/man/man1/lex.1

}

pck_build_tcl() {
    SRCDIR=$(pwd)
    cd unix
    ./configure --prefix=/usr           \
                --mandir=/usr/share/man \
                --disable-rpath

    make

    sed -e "s|$SRCDIR/unix|/usr/lib|" \
        -e "s|$SRCDIR|/usr/include|"  \
        -i tclConfig.sh

    sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.13|/usr/lib/tdbc1.1.13|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.13/generic|/usr/include|"     \
        -e "s|$SRCDIR/pkgs/tdbc1.1.13/library|/usr/lib/tcl8.6|"  \
        -e "s|$SRCDIR/pkgs/tdbc1.1.13|/usr/include|"             \
        -i pkgs/tdbc1.1.13/tdbcConfig.sh

    sed -e "s|$SRCDIR/unix/pkgs/itcl4.3.7|/usr/lib/itcl4.3.7|" \
        -e "s|$SRCDIR/pkgs/itcl4.3.7/generic|/usr/include|"    \
        -e "s|$SRCDIR/pkgs/itcl4.3.7|/usr/include|"            \
        -i pkgs/itcl4.3.7/itclConfig.sh

    unset SRCDIR

    make install 
    chmod 644 /usr/lib/libtclstub8.6.a

    chmod -v u+w /usr/lib/libtcl8.6.so

    make install-private-headers

    ln -sfv tclsh8.6 /usr/bin/tclsh

    mv -v /usr/share/man/man3/{Thread,Tcl_Thread}.3

    cd ..
    tar -xf /sources/tcl8.6.18-html.tar.gz --strip-components=1
    mkdir -v -p /usr/share/doc/tcl-8.6.18
    cp -v -r  ./html/* /usr/share/doc/tcl-8.6.18
}

pck_build_expect() {
    python3 -c 'from pty import spawn; spawn(["echo", "ok"])'

    patch -Np1 -i /sources/expect-5.45.4-gcc15-1.patch

    ./configure --prefix=/usr           \
                --with-tcl=/usr/lib     \
                --enable-shared         \
                --disable-rpath         \
                --mandir=/usr/share/man \
                --with-tclinclude=/usr/include
    
    make
    make install
    ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

}

pck_build_dejagnu() {
    mkdir -v build
    cd       build

    ../configure --prefix=/usr
    makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
    makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi

    make install
    install -v -dm755  /usr/share/doc/dejagnu-1.6.3
    install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
}

pck_build_ninja() {
    sed -i '/int Guess/a \
        int   j = 0;\
        char* jobs = getenv( "NINJAJOBS" );\
        if ( jobs != NULL ) j = atoi( jobs );\
        if ( j > 0 ) return j;\
        ' src/ninja.cc

    python3 configure.py --bootstrap --verbose

    install -vm755 ninja /usr/bin/
    install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
    install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja
}

pck_build_pkgconf() {
    tar -xf /sources/meson-1.12.0.tar.gz

    mkdir build
    cd    build

    python3 ../meson-1.12.0/meson.py setup --prefix=/usr --buildtype=release ..
    ninja

    ninja install
    mv /usr/share/doc/pkgconf{,-3.0.5}
    ln -sv pkgconf   /usr/bin/pkg-config
    ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1

ln -sv pkgconf /usr/bin/i686-pc-linux-gnu-pkg-config
ln -sv pkgconf /usr/bin/x86_64-pc-linux-gnu-pkg-config

mkdir -pv /usr/share/pkgconfig/personality.d

cat > /usr/share/pkgconfig/personality.d/i686-pc-linux-gnu.personality << EOF
Triplet: i686-pc-linux-gnu
SysrootDir: /
DefaultSearchPaths: /usr/lib32/pkgconfig:/usr/share/pkgconfig
SystemIncludePaths: /usr/include
SystemLibraryPaths: /usr/lib32
EOF

cat > /usr/share/pkgconfig/personality.d/x86_64-pc-linux-gnu.personality << EOF
Triplet: x86_64-pc-linux-gnu
SysrootDir: /
DefaultSearchPaths: /usr/lib/pkgconfig:/usr/share/pkgconfig
SystemIncludePaths: /usr/include
SystemLibraryPaths: /usr/lib
EOF

}

pck_build_binutils() {
    mkdir -v build
    cd       build

    ../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --enable-new-dtags  \
             --with-system-zlib  \
             --with-lib-path=/usr/lib \
             --enable-default-hash-style=gnu

    make tooldir=/usr

    make tooldir=/usr install

    rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a \
        /usr/share/doc/gprofng/
}

pck_build_gmp() {
    sed -i '/long long t1;/,+1s/()/(...)/' configure

    ./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0
    make
    make html
    make install
    make install-html
    make distclean

    cp -v configfsf.guess config.guess
    cp -v configfsf.sub   config.sub

    CFLAGS="-m32 -O2 -pedantic -fomit-frame-pointer -mtune=generic -march=i686" \
    CXXFLAGS="$CFLAGS"                     \
    ABI="32"                               \
    PKG_CONFIG_PATH="/usr/lib32/pkgconfig" \
    ./configure --prefix=/usr              \
                --host=i686-pc-linux-gnu   \
                --disable-static           \
                --enable-cxx               \
                --libdir=/usr/lib32        \
                --includedir=/usr/include/m32/gmp
    sed -i 's/$(exec_prefix)\/include/$\(includedir\)/' Makefile
    make
    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    cp -Rv DESTDIR/usr/include/m32/* /usr/include/m32/
    rm -rf DESTDIR

}

pck_build_mpfr() {
    ./configure --prefix=/usr        \
                --disable-static     \
                --enable-thread-safe \
                --docdir=/usr/share/doc/mpfr-4.2.2
    make
    make html
    make install
    make install-html

}

pck_build_mpc() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.4.1
    make
    make html
    make install
    make install-html

}

pck_build_isl() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/isl-0.28
    make
    make install
    install -vd /usr/share/doc/isl-0.28
    install -m644 doc/{CodingStyle,manual.pdf,SubmittingPatches,user.pod} \
            /usr/share/doc/isl-0.28

    mkdir -pv /usr/share/gdb/auto-load/usr/lib
    mv -v /usr/lib/libisl*gdb.py /usr/share/gdb/auto-load/usr/lib
}

pck_build_attr() {
    ./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.6.0

    make
    make install

    make distclean

    CC="gcc -m32" ./configure \
        --prefix=/usr         \
        --disable-static      \
        --sysconfdir=/etc     \
        --libdir=/usr/lib32   \
        --host=i686-pc-linux-gnu

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_acl() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/acl-2.4.0
    make
    make install

    make distclean

    CC="gcc -m32" ./configure   \
        --prefix=/usr           \
        --disable-static        \
        --libdir=/usr/lib32     \
        --libexecdir=/usr/lib32 \
        --host=i686-pc-linux-gnu

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_libcap() {
    sed -i '/install -m.*STA/d' libcap/Makefile

    make prefix=/usr lib=lib
    make prefix=/usr lib=lib install
    make distclean

    make CC="gcc -m32 -march=i686"

    make CC="gcc -m32 -march=i686" lib=lib32 prefix=$PWD/DESTDIR/usr -C libcap install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    sed -e "s|^libdir=.*|libdir=/usr/lib32|" -i /usr/lib32/pkgconfig/lib{cap,psx}.pc
    chmod -v 755 /usr/lib32/libcap.so.2.78
    rm -rf DESTDIR

}

pck_build_libxcrypt() {
    sed -i '/strchr/s/const//' lib/crypt-{sm3,gost}-yescrypt.c

    ./configure --prefix=/usr                \
                --enable-hashes=strong,glibc \
                --enable-obsolete-api=no     \
                --disable-static             \
                --disable-failure-tokens

    make
    make install

    make distclean

    CC="gcc -m32"                            \
    ./configure --prefix=/usr                \
                --host=i686-pc-linux-gnu     \
                --libdir=/usr/lib32          \
                --enable-hashes=strong,glibc \
                --enable-obsolete-api=glibc  \
                --disable-static             \
                --disable-failure-tokens

    make

    cp -av .libs/libcrypt.so* /usr/lib32/
    make install-pkgconfigDATA
    ln -svf libxcrypt.pc /usr/lib32/pkgconfig/libcrypt.pc
}

pck_build_shadow() {
    find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
    find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

    sed -e 's:#ENCRYPT_METHOD SHA512:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                      \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                     \
    -i etc/login.defs

    touch /usr/bin/passwd
    ./configure --sysconfdir=/etc   \
                --disable-static    \
                --with-{b,yes}crypt \
                --without-libbsd    \
                --disable-logind    \
                --with-group-name-max-length=32
    
    make
    make exec_prefix=/usr install
    make -C man install-man

    pwconv

    grpconv

    mkdir -p /etc/default
    useradd -D --gid 999

    sed -i '/MAIL/s/yes/no/' /etc/default/useradd
    touch /etc/sub{u,g}id

}

pck_build_gawk() {
    sed -i 's/extras//' Makefile.in

    ./configure --prefix=/usr

    make

    rm -f /usr/bin/gawk-5.4.1
    make install

    rm -f /usr/bin/gawk-5.4.1

    ln -sv gawk.1 /usr/share/man/man1/awk.1

    install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} -t /usr/share/doc/gawk-5.4.1

}

pck_build_gcc() {
    sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64

    sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' \
      -i gcc/config/i386/i386.h

    mkdir -v build
    cd       build

    ../configure --prefix=/usr                \
             LD=ld                        \
             --enable-languages=c,c++     \
             --enable-default-pie         \
             --enable-default-ssp         \
             --enable-host-pie            \
             --enable-multilib            \
             --with-multilib-list=m64,m32 \
             --disable-bootstrap          \
             --disable-fixincludes        \
             --with-system-zlib
    make
    make install

    ln -svr /usr/bin/cpp /usr/lib
    ln -sv gcc.1 /usr/share/man/man1/cc.1
    ln -sfvr $(gcc -print-prog-name=liblto_plugin.so) /usr/lib/bfd-plugins/

    mkdir -pv /usr/share/gdb/auto-load/usr/lib
    mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
}

pck_build_ncurses() {
    ./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib/pkgconfig

    make
    make DESTDIR=$PWD/dest install
    sed -e 's/^#if.*XOPEN.*$/#if 1/' \
        -i dest/usr/include/curses.h
    cp --remove-destination -av dest/* /

    for lib in ncurses form panel menu ; do
        ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
        ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
    done

    ln -sfv libncursesw.so /usr/lib/libcurses.so

    cp -v -R doc -T /usr/share/doc/ncurses-6.6

    make distclean

    CC="gcc -m32" CXX="g++ -m32"         \
    ./configure --prefix=/usr            \
                --host=i686-pc-linux-gnu \
                --libdir=/usr/lib32      \
                --mandir=/usr/share/man  \
                --with-shared            \
                --without-debug          \
                --without-normal         \
                --with-cxx-shared        \
                --enable-pc-files        \
                --with-pkg-config-libdir=/usr/lib32/pkgconfig

    make

    make DESTDIR=$PWD/DESTDIR install
    mkdir -p DESTDIR/usr/lib32/pkgconfig
    for lib in ncurses form panel menu ; do
        rm -vf                    DESTDIR/usr/lib32/lib${lib}.so
        echo "INPUT(-l${lib}w)" > DESTDIR/usr/lib32/lib${lib}.so
        ln -svf ${lib}w.pc        DESTDIR/usr/lib32/pkgconfig/$lib.pc
    done
    rm -vf                     DESTDIR/usr/lib32/libcursesw.so
    echo "INPUT(-lncursesw)" > DESTDIR/usr/lib32/libcursesw.so
    ln -sfv libncurses.so      DESTDIR/usr/lib32/libcurses.so
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_sed() {
    ./configure --prefix=/usr

    make
    make html

    make install
    install -vDm644 doc/sed.html -t /usr/share/doc/sed-4.10
}

pck_build_psmisc() {
    ./configure --prefix=/usr
    make
    make install
}

pck_build_gettext() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-1.0
    make
    make install
    chmod -v 0755 /usr/lib/preloadable_libintl.so
}

pck_build_bison() {
    ./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
    make
    make install
}

pck_build_grep() {
    sed -i "s/echo/#echo/" src/egrep.sh

    ./configure --prefix=/usr
    make
    make install

}

pck_build_bash() {
    ./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.3

    make
    make install

}

pck_build_libtool() {
    ./configure --prefix=/usr
    make
    make install
    rm -fv /usr/lib/libltdl.a
    make distclean
    CC="gcc -m32" ./configure    \
        --host=i686-pc-linux-gnu \
        --prefix=/usr            \
        --libdir=/usr/lib32

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_gdbm() {
    ./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat
    make
    make install
    make distclean

    CC="gcc -m32" CXX="g++ -m32"         \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static         \
                --enable-libgdbm-compat

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32/
    rm -rf DESTDIR

}

pck_build_gperf() {
    ./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.3
    make
    make install
}

pck_build_expat() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.8.3
    make
    make install

    install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.8.3

    sed -e "/^am__append_1/ s/doc//" -i Makefile
    make clean

    CC="gcc -m32"                        \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_inetutils() {
    sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c

    ./configure --prefix=/usr        \
                --bindir=/usr/bin    \
                --localstatedir=/var \
                --disable-logger     \
                --disable-whois      \
                --disable-rcp        \
                --disable-rexec      \
                --disable-rlogin     \
                --disable-rsh        \
                --disable-servers

    make
    make install

    mv -v /usr/{,s}bin/ifconfig
}

pck_build_less() {
    ./configure --prefix=/usr --sysconfdir=/etc
    make
    make install
}

pck_build_perl() {
    export BUILD_ZLIB=False
    export BUILD_BZIP2=0

    sh Configure -des                                          \
                -D prefix=/usr                                \
                -D vendorprefix=/usr                          \
                -D privlib=/usr/lib/perl5/5.44/core_perl      \
                -D archlib=/usr/lib/perl5/5.44/core_perl      \
                -D sitelib=/usr/lib/perl5/5.44/site_perl      \
                -D sitearch=/usr/lib/perl5/5.44/site_perl     \
                -D vendorlib=/usr/lib/perl5/5.44/vendor_perl  \
                -D vendorarch=/usr/lib/perl5/5.44/vendor_perl \
                -D man1dir=/usr/share/man/man1                \
                -D man3dir=/usr/share/man/man3                \
                -D pager="/usr/bin/less -isR"                 \
                -D useshrplib                                 \
                -D usethreads

    make
    make install

}

pck_build_autoconf() {
    ./configure --prefix=/usr
    make
    make install
}

pck_build_automake() {
    ./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.18.1
    make
    make install

}

pck_build_openssl() {
    ./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
    make
    make INSTALL_LIBS= MANSUFFIX=ssl install

    mv -v /usr/share/doc/openssl /usr/share/doc/openssl-4.0.1

    cp -vfr doc/* /usr/share/doc/openssl-4.0.1

    make distclean
    ./config --prefix=/usr         \
            --openssldir=/etc/ssl \
            --libdir=lib32        \
            shared                \
            zlib-dynamic          \
            no-docs               \
            linux-x86

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_libelf() {
    ./configure --prefix=/usr        \
            --disable-debuginfod \
            --enable-libdebuginfod=dummy

    make -C lib
    make -C libelf

    make -C libelf install
    install -vm644 config/libelf.pc /usr/lib/pkgconfig
    rm /usr/lib/libelf.a

    make distclean

    CC="gcc -m32" CXX="g++ -m32"         \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-debuginfod     \
                --enable-libdebuginfod=dummy

    make -C lib
    make -C libelf

    make DESTDIR=$PWD/DESTDIR -C libelf install
    install -vDm644 config/libelf.pc DESTDIR/usr/lib32/pkgconfig/libelf.pc
    rm -vf DESTDIR/usr/lib32/libelf.a
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_libffi() {
    ./configure --prefix=/usr    \
            --disable-static \
            --with-gcc-arch=native
    make
    make install

    make distclean

    CC="gcc -m32" CXX="g++ -m32"         \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static         \
                --with-gcc-arch=i686

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_sqlite() {
    python3 -m zipfile -e /sources/sqlite-doc-3530400.zip .

    ./configure --prefix=/usr     \
                --disable-static  \
                --enable-fts{4,5} \
                CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 \
                        -D SQLITE_ENABLE_UNLOCK_NOTIFY=1   \
                        -D SQLITE_ENABLE_DBSTAT_VTAB=1     \
                        -D SQLITE_SECURE_DELETE=1"

    make LDFLAGS.rpath=""

    make install

    cp -v -R sqlite-doc-3530400 -T /usr/share/doc/sqlite-3.53.4

    make distclean

    CC="gcc -m32" CXX="g++ -m32"         \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static         \
                --enable-fts{4,5}        \
                CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 \
                        -D SQLITE_ENABLE_UNLOCK_NOTIFY=1   \
                        -D SQLITE_ENABLE_DBSTAT_VTAB=1     \
                        -D SQLITE_SECURE_DELETE=1"

    make LDFLAGS.rpath=""

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_mpdecimal() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpdecimal-4.0.1

    make 
    make install
}

pck_build_python() {
    patch -Np1 -i /sources/Python-3.14.7-openssl_4-1.patch

    ./configure --prefix=/usr          \
            --enable-shared        \
            --with-system-expat    \
            --enable-optimizations \
            --without-static-libpython

    make
    make install

cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF


}

pck_build_flitcore() {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
    pip3 install --no-index --find-links dist flit_core
}

pck_build_packaging() {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

    pip3 install --no-index --find-links dist packaging
}

pck_build_wheel() {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

    pip3 install --no-index --find-links dist wheel
}

pck_build_setuptools() {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

    pip3 install --no-index --find-links dist setuptools
}

pck_build_meson() {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

    pip3 install --no-index --find-links dist meson
    install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
    install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

mkdir -pv /usr/share/meson/cross
mkdir -pv /usr/share/meson/native
for i in {cross/lib32,native/x86}; do
cat > /usr/share/meson/$i << "EOF"
[binaries]
c = ['gcc', '-m32']
cpp = ['g++', '-m32']
rust = ['rustc', '--target', 'i686-unknown-linux-gnu']
pkg-config = 'i686-pc-linux-gnu-pkg-config'
ar = '/usr/bin/ar'
strip = '/usr/bin/strip'
cups-config = 'cups-config'
llvm-config = 'llvm-config'
exe_wrapper = ''

[built-in options]
libdir = 'lib32'

[properties]
sizeof_void* = 4
sizeof_long = 4

[host_machine]
system = 'linux'
subsystem = 'linux'
kernel = 'linux'
cpu_family = 'x86'
cpu = 'i686'
endian = 'little'
EOF
done
}

pck_build_kmod() {
    mkdir -p build
    cd       build

    meson setup --prefix=/usr ..    \
                --buildtype=release \
                -D manpages=false
    ninja
    ninja install

    rm -rf *

    meson setup --prefix=/usr       \
                --buildtype=release \
                --cross-file=lib32  \
                -D manpages=false   \
                ..

    ninja

    DESTDIR=$PWD/DESTDIR ninja install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_coreutils() {
    patch -Np1 -i /sources/coreutils-9.11-i18n-1.patch

    autoreconf -fv
    automake -af
    FORCE_UNSAFE_CONFIGURE=1 ./configure \
                --prefix=/usr

    make
    make install

    mv -v /usr/bin/chroot /usr/sbin
    mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
                
}

pck_build_diffutils() {
    ./configure --prefix=/usr
    make
    make install

}

pck_build_findutils() {
    ./configure --prefix=/usr --localstatedir=/var/lib/locate
    make
    make install

}

pck_build_groff() {
    PAGE=letter ./configure --prefix=/usr

    make -j1
    make install
}

pck_build_grub() {
    sed 's/--image-base/--nonexist-linker-option/' -i configure

    ./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-efiemu  \
            --disable-werror

    make
    make install

    make clean

    ./configure --prefix=/usr       \
            --sysconfdir=/etc   \
            --target=x86_64     \
            --with-platform=efi \
            --disable-efiemu    \
            --disable-werror

    make
    make install

    make clean

    ./configure --prefix=/usr       \
                --sysconfdir=/etc   \
                --target=i386       \
                --with-platform=efi \
                --disable-efiemu    \
                --disable-werror

    make 
    make install
}

pck_build_gzip() {
    ./configure --prefix=/usr
    make
    make install
}

pck_build_iproute2() {
    sed -i /ARPD/d Makefile
    rm -fv man/man8/arpd.8

    make NETNS_RUN_DIR=/run/netns

    make SBINDIR=/usr/sbin install

    install -vDm644 COPYING README* -t /usr/share/doc/iproute2-7.1.0
}

pck_build_kbd() {
    patch -Np1 -i /sources/kbd-2.10.0-backspace-1.patch

    sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
    sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

    ./configure --prefix=/usr --disable-vlock
    make
    make install
    cp -R -v docs/doc -T /usr/share/doc/kbd-2.10.0
}

pck_build_libpipeline() {
    ./configure --prefix=/usr
    make
    make install
}

pck_build_make() {
    ./configure --prefix=/usr
    make
    make install
}

pck_build_patch() {
    ./configure --prefix=/usr
    make
    make install

}

pck_build_tar() {
    patch -Np1 -i /sources/tar-1.35-acl_fix-1.patch

    FORCE_UNSAFE_CONFIGURE=1  \
    ./configure --prefix=/usr
    make
    make install
    make -C doc install-html docdir=/usr/share/doc/tar-1.35
}

pck_build_texinfo() {
    ./configure --prefix=/usr
    make
    make install
    make TEXMF=/usr/share/texmf install-tex

}

pck_build_vim() {
    echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
    ./configure --prefix=/usr
    make
    make install
    ln -sv vim /usr/bin/vi

    for L in  /usr/share/man/{,*/}man1/vim.1; do
        ln -sv vim.1 $(dirname $L)/vi.1
    done

    ln -sv ../vim/vim92/doc /usr/share/doc/vim-9.2.1025
}

pck_build_markupsafe() {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
    pip3 install --no-index --find-links dist Markupsafe
}

pck_build_jinja2() {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

    pip3 install --no-index --find-links dist Jinja2
}

pck_build_systemd() {
    sed -e 's/GROUP="render"/GROUP="video"/' \
    -e 's/GROUP="sgx", //'               \
    -i rules.d/50-udev-default.rules.in

    mkdir -p build
    cd       build

    meson setup ..                \
        --prefix=/usr           \
        --buildtype=release     \
        -D default-dnssec=no    \
        -D firstboot=false      \
        -D install-tests=false  \
        -D ldconfig=false       \
        -D sysusers=false       \
        -D rpmmacrosdir=no      \
        -D homed=disabled       \
        -D man=disabled         \
        -D mode=release         \
        -D pamconfdir=no        \
        -D dev-kvm-mode=0660    \
        -D nobody-group=nogroup \
        -D sysupdate=disabled   \
        -D ukify=disabled       \
        -D docdir=/usr/share/doc/systemd-261.2

    ninja
    ninja install

    tar -xf /sources/systemd-man-pages-261.2.tar.xz \
        --no-same-owner --strip-components=1     \
        -C /usr/share/man

    systemd-machine-id-setup
    systemctl preset-all

    rm -rf *

    LANG=en_US.UTF-8                    \
    meson setup --prefix=/usr           \
                --buildtype=release     \
                --cross-file=lib32      \
                -D default-dnssec=no    \
                -D firstboot=false      \
                -D install-tests=false  \
                -D ldconfig=false       \
                -D sysusers=false       \
                -D rpmmacrosdir=no      \
                -D homed=disabled       \
                -D userdb=false         \
                -D man=disabled         \
                -D mode=release         \
                -D nobody-group=nogroup \
                -D sysupdate=disabled   \
                -D ukify=disabled       \
                ..
    
    LANG=en_US.UTF-8 ninja

    LANG=en_US.UTF-8 DESTDIR=$PWD/DESTDIR ninja install
    cp -av DESTDIR/usr/lib32/libsystemd.so* /usr/lib32/
    cp -av DESTDIR/usr/lib32/libudev.so* /usr/lib32/
    cp -v  DESTDIR/usr/lib32/pkgconfig/* /usr/lib32/pkgconfig/
    rm -rf DESTDIR
}

pck_build_dbus() {
    mkdir build
    cd    build

    meson setup --prefix=/usr --buildtype=release --wrap-mode=nofallback ..

    ninja
    ninja install

    ln -sfv /etc/machine-id /var/lib/dbus

    rm -rf *

    meson setup --prefix=/usr          \
                --buildtype=release    \
                --cross-file=lib32     \
                --wrap-mode=nofallback \
                ..

    ninja

    DESTDIR=$(pwd)/destdir ninja install
    mkdir -pv /usr/lib32/pkgconfig
    cp -av $(pwd)/destdir/usr/lib32/libdbus-1.so* /usr/lib32/
    cp -av $(pwd)/destdir/usr/lib32/dbus-1.0 /usr/lib32/
    cp -v  $(pwd)/destdir/usr/lib32/pkgconfig/dbus-1.pc /usr/lib32/pkgconfig/
}

pck_build_mandb() {
    ./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.13.1 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap

    make
    make install

}

pck_build_procpsng() {
    ./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.7 \
            --disable-static                        \
            --disable-kill                          \
            --enable-watch8bit                      \
            --with-systemd

    make
    make install
}

pck_build_utillinux() {
    ./configure --bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-liblastlog2 \
            --disable-static      \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.42.2

    make

    make install

    make distclean

    mv /usr/bin/ncursesw6-config{,.tmp}

    CC="gcc -m32"                        \
    ./configure --host=i686-pc-linux-gnu \
                --libdir=/usr/lib32      \
                --runstatedir=/run       \
                --sbindir=/usr/sbin      \
                --disable-chfn-chsh      \
                --disable-login          \
                --disable-nologin        \
                --disable-su             \
                --disable-setpriv        \
                --disable-runuser        \
                --disable-pylibmount     \
                --disable-liblastlog2    \
                --disable-static         \
                --without-python         \
                ADJTIME_PATH=/var/lib/hwclock/adjtime

    mv /usr/bin/ncursesw6-config{.tmp,}

    make

    make DESTDIR=$PWD/DESTDIR install
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32
    rm -rf DESTDIR
}

pck_build_e2fsprogs() {
    mkdir -v build
    cd       build

    ../configure --prefix=/usr       \
                --sysconfdir=/etc   \
                --enable-elf-shlibs \
                --disable-libblkid  \
                --disable-libuuid   \
                --disable-uuidd     \
                --disable-fsck

    make
    make install

    rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

    gunzip -v /usr/share/info/libext2fs.info.gz
    install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

    makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
    install -v -m644 doc/com_err.info /usr/share/info
    install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

    sed 's/metadata_csum_seed,//' -i /etc/mke2fs.conf
}

pck_build_cleanup() {
    echo "Cleaning up..."
    rm -rf /tmp/{*,.*}
    find /usr/lib{,32,exec} -name \*.la -delete || true
    find /usr -depth -name x86_64-lfs-linux-gnu\* | xargs rm -rf || true
}

pck_build_initconfig() {
    systemctl disable systemd-networkd-wait-online
    ln -s /dev/null /etc/systemd/network/99-default.link

cat > /etc/systemd/network/10-eth-dhcp.network << "EOF"
[Match]
Name=eth0

[Network]
DHCP=ipv4

[DHCPv4]
UseDomains=true
EOF

cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

nameserver 8.8.8.8

# End /etc/resolv.conf
EOF

    echo "plx" > /etc/hostname

cat > /etc/hosts << "EOF"
# Begin /etc/hosts

::1       ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters
127.0.0.1   localhost

# End /etc/hosts
EOF

cat > /etc/adjtime << "EOF"
0.0 0 0.0
0
LOCAL
EOF

cat > /etc/locale.conf << "EOF"
LANG=en_US.UTF-8
EOF

cat > /etc/profile << "EOF"
# Begin /etc/profile

for i in $(locale); do
  unset ${i%=*}
done

if [[ "$TERM" = linux ]]; then
  export LANG=C.UTF-8
else
  source /etc/locale.conf

  for i in $(locale); do
    key=${i%=*}
    if [[ -v $key ]]; then
      export $key
    fi
  done
fi

# End /etc/profile
EOF

cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8-bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# uncomment for history search mode with up/down
# "\e[A": history-search-backward
# "\e[B": history-search-forward

# End /etc/inputrc
EOF

cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF


cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

/dev/nvme2n1p6     /            ext2    defaults            1     1

# End /etc/fstab
EOF

}

pck_build_kernel() {
    cd ..
    mkdir -p /usr/src/
    rm -rf /usr/src/linux

    mv linux-7.1.8 /usr/src/linux

    cd /usr/src/linux
    make mrproper
    cp /sources/.config .
    #make menuconfig
    make
    make modules_install

    cp -iv arch/x86/boot/bzImage /boot/vmlinuz-7.1.8
    cp -iv System.map /boot/System.map-7.1.8
    cp -iv .config /boot/config-7.1.8
    cp -r Documentation -T /usr/share/doc/linux-7.1.8

install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

}

pck_build_post_core() {
echo "MLFS #c67e8" > /etc/lfs-release
cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="MLFS #c67e8"
DISTRIB_CODENAME="<your name here>"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

cat > /etc/os-release << "EOF"
NAME="Linux From Scratch"
VERSION="MLFS #c67e8"
ID=lfs
PRETTY_NAME="Multilib Linux From Scratch #c67e8"
VERSION_CODENAME="<your name here>"
HOME_URL="https://www.linuxfromscratch.org/lfs/"
RELEASE_TYPE="development"
EOF

passwd root

}

pck_build_nvidia_driver() {
    cd /tmp/build
    
    sh /sources/NVIDIA-Linux-x86_64-610.57.04.run -z \
        -j $(nproc)   \
        -k `uname -r` \
        --no-peermem  \
        --override-file-type-destination=OPENCL_WRAPPER_LIB:/tmp/nvidia \
        --override-file-type-destination=OPENCL_WRAPPER_SYMLINK:/tmp/nvidia
}


pck_build_bashstartup() {
    cat > /etc/profile << "EOF"
# Begin /etc/profile
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>
# modifications by Dagmar d'Surreal <rivyqntzne@pbzpnfg.arg>

# System wide environment variables and startup programs.

# System wide aliases and functions should go in /etc/bashrc.  Personal
# environment variables and startup programs should go into
# ~/.bash_profile.  Personal aliases and functions should go into
# ~/.bashrc.

# Functions to help us manage paths.  Second argument is the name of the
# path variable to be modified (default: PATH)
pathremove () {
        local IFS=':'
        local NEWPATH
        local DIR
        local PATHVARIABLE=${2:-PATH}
        for DIR in ${!PATHVARIABLE} ; do
                if [ "$DIR" != "$1" ] ; then
                  NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
                fi
        done
        export $PATHVARIABLE="$NEWPATH"
}

pathprepend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
}

pathappend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}$1"
}

export -f pathremove pathprepend pathappend

# Set the initial path
export PATH=/usr/bin

# Attempt to provide backward compatibility with LFS earlier than 11
if [ ! -L /bin ]; then
        pathappend /bin
fi

if [ $EUID -eq 0 ] ; then
        pathappend /usr/sbin
        if [ ! -L /sbin ]; then
                pathappend /sbin
        fi
        unset HISTFILE
fi

# Set up some environment variables.
export HISTSIZE=1000
export HISTIGNORE="&:[bf]g:exit"
export XDG_DATA_DIRS=${XDG_DATA_DIRS:-/usr/share}
export XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-/etc/xdg}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/tmp/xdg-$USER}

for script in /etc/profile.d/*.sh ; do
        if [ -r $script ] ; then
                . $script
        fi
done

unset script

# End /etc/profile
EOF

install --directory --mode=0755 --owner=root --group=root /etc/profile.d

cat > /etc/profile.d/extrapaths.sh << "EOF"
if [ -d /usr/local/lib/pkgconfig ] ; then
        pathappend /usr/local/lib/pkgconfig PKG_CONFIG_PATH
fi
if [ -d /usr/local/bin ]; then
        pathprepend /usr/local/bin
fi
if [ -d /usr/local/sbin -a $EUID -eq 0 ]; then
        pathprepend /usr/local/sbin
fi

if [ -d /usr/local/share ]; then
        pathprepend /usr/local/share XDG_DATA_DIRS
fi

# Set some defaults before other applications add to these paths.
pathappend /usr/share/info INFOPATH
EOF

cat > /etc/profile.d/readline.sh << "EOF"
# Set up the INPUTRC environment variable.
if [ -z "$INPUTRC" -a ! -f "$HOME/.inputrc" ] ; then
        INPUTRC=/etc/inputrc
fi
export INPUTRC
EOF

cat > /etc/profile.d/umask.sh << "EOF"
# By default, the umask should be set.
if [ "$(id -gn)" = "$(id -un)" -a $EUID -gt 99 ] ; then
  umask 002
else
  umask 022
fi
EOF

cat > /etc/profile.d/i18n.sh << "EOF"
# Set up i18n variables
for i in $(locale); do
  unset ${i%=*}
done

if [[ "$TERM" = linux ]]; then
  export LANG=C.UTF-8
else
  source /etc/locale.conf

  for i in $(locale); do
    key=${i%=*}
    if [[ -v $key ]]; then
      export $key
    fi
  done
fi
EOF

cat > /etc/profile.d/dircolors.sh << "EOF"
# Setup for /bin/ls and /bin/grep to support color
if [ -f "/etc/dircolors" ] ; then
        eval $(dircolors -b /etc/dircolors)
fi

if [ -f "$HOME/.dircolors" ] ; then
        eval $(dircolors -b $HOME/.dircolors)
fi
EOF

cat > /etc/profile.d/aliases.sh << "EOF"
# Make ls, grep, and diff use --color=auto
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
EOF

cat > /root/.bash_profile << "EOF"
echo "LOADING PROFILE"
source /etc/profile
EOF

}

pck_build_icu() {
    cd source                                    
    ./configure --prefix=/usr
    make
    make install
    make clean 
    CC="gcc -m32" CXX="g++ -m32"         \
    PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
    ./configure --prefix=/usr --libdir=/usr/lib32 --host=i686-pc-linux-gnu 
    make
    make DESTDIR=$PWD/DESTDIR install     
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig

}

pck_build_libxml2() {
    pkgconf --list-all

    echo "NEXT"

    #/usr/bin/i686-pc-linux-gnu-pkg-config --list-all

    sed -i "/'git'/,+3d" meson.build

    mkdir build &&
    cd    build &&

    meson setup --prefix=/usr       \
                --buildtype=release \
                -D history=enabled  \
                -D icu=enabled 
    ninja
    ninja install 
    sed 's/--static/--shared/' -i /usr/bin/xml2-config

    rm -rf * 
    meson setup --prefix=/usr            \
                --buildtype=release      \
                --cross-file=lib32       \
                -D history=enabled       \
                -D icu=enabled 
    ninja


    DESTDIR=$PWD/DESTDIR ninja install    
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_nghttp2() {
    ./configure --prefix=/usr     \
            --disable-static  \
            --enable-lib-only \
            --docdir=/usr/share/doc/nghttp2-1.70.0 &&
    make
    make install

    make distclean 
    CC="gcc -m32" CXX="g++ -m32"         \
    PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static         \
                --enable-lib-only       
    make


    make DESTDIR=$PWD/DESTDIR install    
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_libtasn1() {
    ./configure --prefix=/usr --disable-static 
    make
    make install

    make distclean 
    CC="gcc -m32" CXX="g++ -m32"         \
    PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static 

    make

    make DESTDIR=$PWD/DESTDIR install     
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig

}

pck_build_nspr() {
    cd nspr 

    sed -i '/^RELEASE/s|^|#|' pr/src/misc/Makefile.in 
    sed -i 's|$(LIBRARY) ||'  config/rules.mk         

    ./configure --prefix=/usr   \
                --with-mozilla  \
                --with-pthreads \
                --enable-64bit 

    make 
    make install

    make distclean 
    CC="gcc -m32" CXX="g++ -m32"   \
    PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --with-mozilla           \
                --with-pthreads          \
                --disable-64bit 

    make

    make DESTDIR=$PWD/DESTDIR install     
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_nss() {
    patch -Np1 -i /sources/nss-standalone-1.patch 

    cd nss 

    make BUILD_OPT=1                        \
        NSPR_INCLUDE_DIR=/usr/include/nspr \
        USE_SYSTEM_ZLIB=1                  \
        ZLIB_LIBS=-lz                      \
        NSS_ENABLE_WERROR=0                \
        USE_64=1                           \
        NSS_USE_SYSTEM_SQLITE=1

    cd ../dist 

    install -vDm755 Linux*/lib/*.so  -t /usr/lib/        
    install -vDm644 Linux*/lib/*.chk -t /usr/lib/        

    install -vdm755                     /usr/include/nss 
    cp -v -RL {public,private}/nss/*    /usr/include/nss 

    install -vDm755 \
    Linux*/bin/{certutil,nss-config,pk12util} \
                                    -t /usr/bin/        

    install -vDm644 Linux*/lib/pkgconfig/nss.pc -t /usr/lib/pkgconfig/

    cd ../nss                                         
    find -name "Linux*.OBJ" -type d -exec rm -rf {} + 
    rm -rf ../dist                                    

    CC="gcc -m32" CXX="g++ -m32"            \
    make BUILD_OPT=1                        \
        NSPR_INCLUDE_DIR=/usr/include/nspr \
        USE_SYSTEM_ZLIB=1                  \
        ZLIB_LIBS=-lz                      \
        NSS_ENABLE_WERROR=0                \
        NSS_USE_SYSTEM_SQLITE=1

    cd ../dist 

    install -vDm755 Linux*/lib/*.so  -t /usr/lib32/           
    install -vDm644 Linux*/lib/*.chk -t /usr/lib32/           
    sed -i 's/lib/lib32/g'                                     \
                    Linux*/lib/pkgconfig/nss.pc               
    install -vDm644                                            \
                    Linux*/lib/pkgconfig/nss.pc                \
                                    -t /usr/lib32/pkgconfig/ 
    ldconfig
}


pck_build_p11kit() {
    sed '20,$ d' -i trust/trust-extract-compat &&

    cat >> trust/trust-extract-compat << "EOF"
# Copy existing anchor modifications to /etc/ssl/local
/usr/libexec/make-ca/copy-trust-modifications

# Update trust stores
/usr/sbin/make-ca -r
EOF

    mkdir p11-build 
    cd    p11-build 

    meson setup --prefix=/usr                   \
                --buildtype=release             \
                -D test=false                   \
                -D trust_paths=/etc/pki/anchors \
                .. 
    ninja


    ninja install 
    ln -sfv /usr/libexec/p11-kit/trust-extract-compat \
            /usr/bin/update-ca-certificates


    rm -rf * 
    meson setup --prefix=/usr                   \
                --buildtype=release             \
                --cross-file=lib32              \
                -D test=false                   \
                -D trust_paths=/etc/pki/anchors \
                .. 
    ninja

    DESTDIR=$PWD/DESTDIR ninja install    
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig

    for lib in lib{,32}; do
    ln -sfv ./pkcs11/p11-kit-trust.so \
            /usr/"$lib"/libnssckbi.so
    done
}

pck_build_makeca() {
    cat >> make-ca << "EOF"
ln -svf /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
EOF

    sed '/mktemp/s/-t //' -i make-ca

    make install 
    install -vdm755 /etc/ssl/local

    /usr/sbin/make-ca -g
}

pck_build_libunistring() {
    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/libunistring-1.4.2 &&

    make
    make install

    make distclean 
    CC="gcc -m32" CXX="g++ -m32"         \
    PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static 

    make

    make DESTDIR=$PWD/DESTDIR install     
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_libidn2() {
    ./configure --prefix=/usr --disable-static 
    make

    make install
    make distclean &&
    CC="gcc -m32" CXX="g++ -m32"         \
    PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
    ./configure --prefix=/usr            \
                --libdir=/usr/lib32      \
                --host=i686-pc-linux-gnu \
                --disable-static 

    make

    make DESTDIR=$PWD/DESTDIR install     
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_libpsl() {
    mkdir build 
    cd    build 

    meson setup --prefix=/usr --buildtype=release 

    ninja
    ninja install

    rm -rf * 
    meson setup --prefix=/usr            \
                --buildtype=release      \
                --cross-file=lib32       \
                .. 
    ninja

    DESTDIR=$PWD/DESTDIR ninja install    
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_curl() {
    mkdir build 
    cd    build 

    ../configure --prefix=/usr                 \
                --disable-static              \
                --with-openssl                \
                --with-ca-path=/etc/ssl/certs 

    make

    make install 

    rm -rf docs/examples/.deps 

    find docs \( -name Makefile\* -o  \
                -name \*.1       -o  \
                -name \*.3       -o  \
                -name CMakeLists.txt \) -delete 

    cp -v -R docs -T /usr/share/doc/curl-8.21.0


    rm -rf * 
    CC="gcc -m32" CXX="g++ -m32"           \
    PKGCONFIG=i686-pc-linux-gnu-pkg-config \
    ../configure --prefix=/usr             \
                --libdir=/usr/lib32       \
                --host=i686-pc-linux-gnu  \
                --disable-static          \
                --with-openssl            \
                --without-brotli          \
                --with-ca-path=/etc/ssl/certs 

    make

    make DESTDIR=$PWD/DESTDIR install     
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_wget() {
    NEW_LINE='#if !defined OPENSSL_NO_SSL3_METHOD '
    NEW_LINE+='&& OPENSSL_VERSION_NUMBER < 0x40000000L'

    sed -i "/SSL3/c $NEW_LINE" src/openssl.c

    unset NEW_LINE

    ./configure --prefix=/usr      \
                --sysconfdir=/etc  \
                --with-ssl=openssl 

    make

    make install
}


pck_build_pam() {
    mkdir build 
    cd    build

    meson setup --prefix=/usr       \
                --buildtype=release \
                -D docs=disabled    \
                .. 
    ninja
    ninja install 
    chmod -v 4755 /usr/sbin/unix_chkpwd

    rm -rf * 
    meson setup --prefix=/usr       \
                --buildtype=release \
                --cross-file=lib32  \
                -D docs=disabled    \
                ..  
    ninja

    DESTDIR=$PWD/DESTDIR ninja install    
    cp -vR DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig

install -vdm755 /etc/pam.d &&
cat > /etc/pam.d/system-account << "EOF" &&
# Begin /etc/pam.d/system-account

account   required    pam_unix.so

# End /etc/pam.d/system-account
EOF

cat > /etc/pam.d/system-auth << "EOF" &&
# Begin /etc/pam.d/system-auth

auth      required    pam_unix.so

# End /etc/pam.d/system-auth
EOF

cat > /etc/pam.d/system-session << "EOF" &&
# Begin /etc/pam.d/system-session

session   required    pam_unix.so

# End /etc/pam.d/system-session
EOF

cat > /etc/pam.d/system-password << "EOF"
# Begin /etc/pam.d/system-password

# use yescrypt hash for encryption, use shadow, and try to use any
# previously defined authentication token (chosen password) set by any
# prior module.
password  required    pam_unix.so       yescrypt shadow try_first_pass

# End /etc/pam.d/system-password
EOF

cat > /etc/pam.d/other << "EOF"
# Begin /etc/pam.d/other

auth        required        pam_warn.so
auth        required        pam_deny.so
account     required        pam_warn.so
account     required        pam_deny.so
password    required        pam_warn.so
password    required        pam_deny.so
session     required        pam_warn.so
session     required        pam_deny.so

# End /etc/pam.d/other
EOF

}

pck_build_shadowpam() {
    find man -name Makefile.in                \
            -exec sed -e 's/getspnam\.3 / /' \
                    -e 's/passwd\.5 / /'   \
                    -i {} \; &&

    sed -e 's@#ENCRYPT_METHOD SHA512@ENCRYPT_METHOD YESCRYPT@' \
        -e 's@/var/spool/mail@/var/mail@'                      \
        -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                     \
        -i etc/login.defs

    ./configure --sysconfdir=/etc   \
                --disable-static    \
                --without-libbsd    \
                --with-{b,yes}crypt &&
    make
    make exec_prefix=/usr pamddir= install
    make -C man install-man

    install -vDm644 /etc/login.defs /etc/login.defs.orig &&
    for FUNCTION in FAIL_DELAY               \
                    FAILLOG_ENAB             \
                    LASTLOG_ENAB             \
                    MAIL_CHECK_ENAB          \
                    OBSCURE_CHECKS_ENAB      \
                    PORTTIME_CHECKS_ENAB     \
                    QUOTAS_ENAB              \
                    CONSOLE MOTD_FILE        \
                    FTMP_FILE NOLOGINS_FILE  \
                    ENV_HZ PASS_MIN_LEN      \
                    SU_WHEEL_ONLY            \
                    CRACKLIB_DICTPATH        \
                    PASS_CHANGE_TRIES        \
                    PASS_ALWAYS_WARN         \
                    CHFN_AUTH ENCRYPT_METHOD \
                    ENVIRON_FILE
    do
        sed -i "s/^${FUNCTION}/# &/" /etc/login.defs
    done

cat > /etc/pam.d/login << "EOF"
# Begin /etc/pam.d/login

# Set failure delay before next prompt to 3 seconds
auth      optional    pam_faildelay.so  delay=3000000

# Check to make sure that the user is allowed to login
auth      requisite   pam_nologin.so

# Check to make sure that root is allowed to login
# Disabled by default. You will need to create /etc/securetty
# file for this module to function. See man 5 securetty.
#auth      required    pam_securetty.so

# Additional group memberships - disabled by default
#auth      optional    pam_group.so

# include system auth settings
auth      include     system-auth

# check access for the user
account   required    pam_access.so

# include system account settings
account   include     system-account

# Set default environment variables for the user
session   required    pam_env.so

# Set resource limits for the user
session   required    pam_limits.so

# Display the message of the day - Disabled by default
#session   optional    pam_motd.so

# Check user's mail - Disabled by default
#session   optional    pam_mail.so      standard quiet

# include system session and password settings
session   include     system-session
password  include     system-password

# End /etc/pam.d/login
EOF

cat > /etc/pam.d/passwd << "EOF"
# Begin /etc/pam.d/passwd

password  include     system-password

# End /etc/pam.d/passwd
EOF


cat > /etc/pam.d/su << "EOF"
# Begin /etc/pam.d/su

# always allow root
auth      sufficient  pam_rootok.so

# Allow users in the wheel group to execute su without a password
# disabled by default
#auth      sufficient  pam_wheel.so trust use_uid

# include system auth settings
auth      include     system-auth

# limit su to users in the wheel group
# disabled by default
#auth      required    pam_wheel.so use_uid

# include system account settings
account   include     system-account

# Set default environment variables for the service user
session   required    pam_env.so

# include system session settings
session   include     system-session

# End /etc/pam.d/su
EOF

cat > /etc/pam.d/chpasswd << "EOF"
# Begin /etc/pam.d/chpasswd

# always allow root
auth      sufficient  pam_rootok.so

# include system auth and account settings
auth      include     system-auth
account   include     system-account
password  include     system-password

# End /etc/pam.d/chpasswd
EOF

sed -e s/chpasswd/newusers/ /etc/pam.d/chpasswd >/etc/pam.d/newusers


cat > /etc/pam.d/chage << "EOF"
# Begin /etc/pam.d/chage

# always allow root
auth      sufficient  pam_rootok.so

# include system auth and account settings
auth      include     system-auth
account   include     system-account

# End /etc/pam.d/chage
EOF

    for PROGRAM in chfn chgpasswd chsh groupadd groupdel \
                groupmems groupmod useradd userdel usermod
    do
        install -vDm644 /etc/pam.d/chage /etc/pam.d/${PROGRAM}
        sed -i "s/chage/$PROGRAM/" /etc/pam.d/${PROGRAM}
    done

    if [ -f /etc/login.access ]; then mv -v /etc/login.access{,.NOUSE}; fi

    if [ -f /etc/limits ]; then mv -v /etc/limits{,.NOUSE}; fi
}

pck_build_systemdpam() {
    sed -i -e 's/GROUP="render"/GROUP="video"/' \
       -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in

    mkdir build 
    cd    build 

    meson setup --prefix=/usr            \
                --buildtype=release      \
                -D default-dnssec=no     \
                -D firstboot=false       \
                -D install-tests=false   \
                -D ldconfig=false        \
                -D man=auto              \
                -D sysusers=false        \
                -D rpmmacrosdir=no       \
                -D homed=disabled        \
                -D mode=release          \
                -D pam=enabled           \
                -D pamconfdir=/etc/pam.d \
                -D dev-kvm-mode=0660     \
                -D nobody-group=nogroup  \
                -D sysupdate=disabled    \
                -D ukify=disabled        \
                -D docdir=/usr/share/doc/systemd-261.2 \
                .. 
    ninja
    ninja install

    rm -rf * 
    LANG=en_US.UTF-8                     \
    meson setup --prefix=/usr            \
                --buildtype=release      \
                --cross-file=lib32       \
                -D default-dnssec=no     \
                -D firstboot=false       \
                -D install-tests=false   \
                -D ldconfig=false        \
                -D man=disabled          \
                -D sysusers=false        \
                -D rpmmacrosdir=no       \
                -D homed=disabled        \
                -D userdb=false          \
                -D mode=release          \
                -D pam=enabled           \
                -D pamconfdir=/etc/pam.d \
                -D nobody-group=nogroup  \
                -D sysupdate=disabled    \
                -D ukify=disabled        \
                .. 

    LANG=en_US.UTF-8 ninja

    LANG=en_US.UTF-8 DESTDIR=$PWD/DESTDIR ninja install          &&
    cp -vR DESTDIR/usr/lib32/security       /usr/lib32           &&
    cp -va DESTDIR/usr/lib32/libsystemd.so* /usr/lib32           &&
    cp -va DESTDIR/usr/lib32/libudev.so*    /usr/lib32           &&
    cp -v  DESTDIR/usr/lib32/pkgconfig/*    /usr/lib32/pkgconfig &&
    rm -rf DESTDIR

    grep 'pam_systemd' /etc/pam.d/system-session ||
cat >> /etc/pam.d/system-session << "EOF"
# Begin Systemd addition

session  required    pam_loginuid.so
session  optional    pam_systemd.so

# End Systemd addition
EOF

cat > /etc/pam.d/systemd-user << "EOF"
# Begin /etc/pam.d/systemd-user

account  required    pam_access.so
account  include     system-account

session  required    pam_env.so
session  required    pam_limits.so
session  required    pam_loginuid.so
session  optional    pam_keyinit.so force revoke
session  optional    pam_systemd.so

auth     required    pam_deny.so
password required    pam_deny.so

# End /etc/pam.d/systemd-user
EOF

install -vDm755 /dev/stdin /etc/systemd/user-environment-generators/50-profile.sh << "EOF"
#!/usr/bin/env -S -i /usr/bin/bash
# SPDX-License-Identifier: MIT

. /etc/profile

# Systemd should have already set a better value for them.
unset XDG_RUNTIME_DIR
for i in $(locale); do
  unset ${i%=*}
done

# Some shell magic that we don't want to expose.
unset SHLVL

# Systemd does not want to pass functions to the environment
for i in $(declare -pF | awk '{print $3}'); do
  unset -f $i
done

python3 << _EOF
import os
for var in os.environ:
  # Simply unsetting them in shell does not work.
  if var in ['LC_CTYPE', '_']:
    continue

  print(var + '=' + os.environ[var])
_EOF
EOF

}

pck_build_duktape() {
    sed -i 's/-Os/-O2/' Makefile.sharedlibrary &&
    make -f Makefile.sharedlibrary INSTALL_PREFIX=/usr

    make -f Makefile.sharedlibrary INSTALL_PREFIX=/usr install
}

pck_build_glib() {
    mkdir build 
    cd    build 

    meson setup --prefix=/usr             \
                --buildtype=release       \
                -D introspection=disabled \
                -D glib_debug=disabled    \
                -D man-pages=disabled     \
                -D tests=false            \
                -D sysprof=disabled       \
                .. 
    ninja
    ninja install

    tar xf /sources/gobject-introspection-1.86.0.tar.xz 

    meson setup gobject-introspection-1.86.0 gi-build \
                --prefix=/usr --buildtype=release     
    ninja -C gi-build

    ninja -C gi-build install

    meson configure -D introspection=enabled 
    ninja
    ninja install

    rm -rf * 
    meson setup --prefix=/usr             \
                --buildtype=release       \
                --cross-file=lib32        \
                -D introspection=disabled \
                -D glib_debug=disabled    \
                -D man-pages=disabled     \
                -D tests=false            \
                -D sysprof=disabled       \
                .. 

    ninja

    DESTDIR=$PWD/DESTDIR ninja install    
    cp -vR DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_shared_mime_info() {
    mkdir build &&
    cd    build 

    meson setup --prefix=/usr         \
                --buildtype=release   \
                -D update-mimedb=true \
                -D build-tests=false  \
                -D build-spec=false   \
                .. 
    ninja

    ninja install

}

pck_build_desktop_file_utils() {
    mkdir build &&
    cd    build 

    meson setup --prefix=/usr --buildtype=release .. 
    ninja

    ninja install
}

pck_build_polkit() {
    groupadd -fg 27 polkitd 
    useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 \
            -g polkitd -s /bin/false polkitd

    mkdir build 
    cd    build 

    meson setup --prefix=/usr                \
                --buildtype=release          \
                -D os_type=lfs               \
                -D man=false                 \
                -D session_tracking=logind   \
                -D tests=false               \
                .. 
    ninja

    ninja install
}

