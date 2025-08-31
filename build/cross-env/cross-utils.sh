#!/bin/sh

STATUS_FILE=$BUILD_DIR/.status
BUILD_USER=$(whoami)

step_is_done() {
  local step="$1"
  grep -Fqx -- "$step" "$STATUS_FILE"
}

mark_step_done() {
  local step="$1"
  sed -i "\|^${step}\$|d" "$STATUS_FILE"
  printf '%s\n' "$step" >> "$STATUS_FILE"
}

run_step() {
  local step="$1"
  if step_is_done "$step"; then
    echo "==> Skipping ${step} (already done)"
    return 0
  fi
  echo "==> Running ${step}..."

  if [[ -n "${1:-}" ]]; then
	  "$step" "$1"
  else
  	"$step"    # call the function
  fi
  
  mark_step_done "$step"
}

plx_format() {
    sudo mkfs.ext4 -v $PLX_DEV
}

plx_mount() {
    sudo mkdir -p $PLX

    if ! mountpoint -q "$PLX"; then
        sudo mount $PLX_DEV $PLX
    fi
}

plx_init() {
    sudo chown root:root $PLX
    sudo chmod 755 $PLX

    sudo mkdir -pv $PLX/{etc,var,tools,lib64} $PLX/usr/{bin,lib,sbin}
    
    for i in bin lib sbin; do
        sudo ln -sv usr/$i $PLX/$i
    done

    sudo chown -v $BUILD_USER $PLX/{usr{,/*},var,etc,tools,lib64}
}

CUR_BUILD_PATH=

prep_build() {
    source=$1

    cd $BUILD_DIR

    plx_download_source $source sources

    rm -rf $BUILD_TMP
    mkdir -p $BUILD_TMP
    pushd $BUILD_TMP

    tar -xf ../sources/$source

    srcpath=$(plx_get_source_path ../sources/$source)

    echo "Prep build: $PWD"

    CUR_BUILD_PATH="$BUILD_TMP/$srcpath"

    popd
}

build_cross_binutils_p1() {
    prep_build binutils-2.44.tar.xz
    pushd $CUR_BUILD_PATH

    mkdir -v build
    cd       build

    ../configure --prefix=$PLX/tools \
             --with-sysroot=$PLX \
             --target=$PLX_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-new-dtags  \
             --enable-default-hash-style=gnu
    make
    make install

    popd
}

build_cross_gcc_p1() {

    prep_build gcc-14.2.0.tar.xz
    pushd $CUR_BUILD_PATH

    plx_download_source mpfr-4.2.1.tar.xz $SOURCES_DIR
    plx_download_source gmp-6.3.0.tar.xz $SOURCES_DIR
    plx_download_source mpc-1.3.1.tar.gz $SOURCES_DIR

    tar -xf $SOURCES_DIR/mpfr-4.2.1.tar.xz
    mv -v mpfr-4.2.1 mpfr
    tar -xf $SOURCES_DIR/gmp-6.3.0.tar.xz
    mv -v gmp-6.3.0 gmp
    tar -xf $SOURCES_DIR/mpc-1.3.1.tar.gz
    mv -v mpc-1.3.1 mpc

    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

    mkdir -v build
    cd       build

    ../configure                  \
        --target=$PLX_TGT         \
        --prefix=$PLX/tools       \
        --with-glibc-version=2.41 \
        --with-sysroot=$PLX       \
        --with-newlib             \
        --without-headers         \
        --enable-default-pie      \
        --enable-default-ssp      \
        --disable-nls             \
        --disable-shared          \
        --disable-multilib        \
        --disable-threads         \
        --disable-libatomic       \
        --disable-libgomp         \
        --disable-libquadmath     \
        --disable-libssp          \
        --disable-libvtv          \
        --disable-libstdcxx       \
        --enable-languages=c,c++

    make
    make install

    cd ..
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
        `dirname $($PLX_TGT-gcc -print-libgcc-file-name)`/include/limits.h

    popd
}

build_cross_linux_headers() {
    prep_build linux-6.13.4.tar.xz
    pushd $CUR_BUILD_PATH

	make mrproper

	make headers
	find usr/include -type f ! -name '*.h' -delete
	cp -rv usr/include $PLX/usr

	popd
}

build_cross_destdir() {
	make
	make DESTDIR=$PLX install
}

build_cross_glibc() {
    prep_build glibc-2.41.tar.xz 
    pushd $CUR_BUILD_PATH

    plx_download_source glibc-2.41-fhs-1.patch $SOURCES_DIR
    patch -Np1 -i $SOURCES_DIR/glibc-2.41-fhs-1.patch

	ln -sfv ../lib/ld-linux-x86-64.so.2 $PLX/lib64/
        ln -sfv ../lib/ld-linux-x86-64.so.2 $PLX/lib64/ld-lsb-x86-64.so.3

	mkdir build
	cd build

	echo "rootsbindir=/usr/sbin" > configparms

	../configure                             \
      		--prefix=/usr                      \
      		--host=$PLX_TGT                    \
      		--build=$(../scripts/config.guess) \
      		--enable-kernel=5.4                \
      		--with-headers=$PLX/usr/include    \
      		--disable-nscd                     \
      		libc_cv_slibdir=/usr/lib

	build_cross_destdir

	sed '/RTLDLIST=/s@/usr@@g' -i $PLX/usr/bin/ldd

	popd
}

build_cross_libstdcpp() {
    prep_build gcc-14.2.0.tar.xz
    pushd $CUR_BUILD_PATH

	mkdir build
	cd build

	../libstdc++-v3/configure           \
    		--host=$PLX_TGT                 \
    		--build=$(../config.guess)      \
    		--prefix=/usr                   \
    		--disable-multilib              \
    		--disable-nls                   \
    		--disable-libstdcxx-pch         \
    		--with-gxx-include-dir=/tools/$PLX_TGT/include/c++/14.2.0

	build_cross_destdir

	rm -v $PLX/usr/lib/lib{stdc++{,exp,fs},supc++}.la

	popd
}

build_cross_m4() {
    prep_build m4-1.4.19.tar.xz
    pushd $CUR_BUILD_PATH

	autoreconf --force
	./configure --prefix=/usr   \
            --host=$PLX_TGT \
            --build=$(build-aux/config.guess)

	echo "MAKING WITHOUT HELP2MAN"

	sed 's/^HELP2MAN/HELP2MAN=echo #/' -i doc/Makefile
	make
	make DESTDIR=$PLX install

	popd
}

build_cross_ncurses() {
    prep_build  ncurses-6.5.tar.gz 
    pushd $CUR_BUILD_PATH

	mkdir build
	pushd build
	  ../configure AWK=gawk
	  make -C include
	  make -C progs tic
	popd

	./configure --prefix=/usr                \
            --host=$PLX_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            AWK=gawk

	make
	make DESTDIR=$PLX TIC_PATH=$(pwd)/build/progs/tic install
	ln -sv libncursesw.so $PLX/usr/lib/libncurses.so
	
	sed -e 's/^#if.*XOPEN.*$/#if 1/' \
	    -i $PLX/usr/include/curses.h

	popd
}

build_cross_bash() {
    prep_build bash-5.2.37.tar.gz 
    pushd $CUR_BUILD_PATH

	./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$PLX_TGT                    \
            --without-bash-malloc

	build_cross_destdir

	ln -sv bash $PLX/bin/sh

	popd
}

build_cross_coreutils() {
    prep_build coreutils-9.6.tar.xz 
    pushd $CUR_BUILD_PATH

	autoreconf --force
	./configure --prefix=/usr                     \
            --host=$PLX_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

	build_cross_destdir

	mv -v $PLX/usr/bin/chroot              $PLX/usr/sbin
	mkdir -pv $PLX/usr/share/man/man8
	mv -v $PLX/usr/share/man/man1/chroot.1 $PLX/usr/share/man/man8/chroot.8
	sed -i 's/"1"/"8"/'                    $PLX/usr/share/man/man8/chroot.8

	popd
}

build_cross_diffutils() {
    prep_build diffutils-3.11.tar.xz 
    pushd $CUR_BUILD_PATH

	./configure --prefix=/usr   \
            --host=$PLX_TGT \
            --build=$(./build-aux/config.guess)

	build_cross_destdir

	popd
}

build_cross_file() {
    prep_build file-5.46.tar.gz  
    pushd $CUR_BUILD_PATH

	autoreconf --force

	mkdir build
	pushd build
	  ../configure --disable-bzlib      \
	               --disable-libseccomp \
	               --disable-xzlib      \
	               --disable-zlib
	  make
	popd

	echo "CONFIGURE"
	./configure --prefix=/usr --host=$PLX_TGT --build=$(./config.guess)

	echo "MAKE"
	make FILE_COMPILE=$(pwd)/build/src/file

	make DESTDIR=$PLX install

	rm -v $PLX/usr/lib/libmagic.la

	popd
}


build_cross_findutils() {
    prep_build findutils-4.10.0.tar.xz 
    pushd $CUR_BUILD_PATH

	autoreconf --force
	./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$PLX_TGT                 \
            --build=$(build-aux/config.guess)

	build_cross_destdir

	popd
}

build_cross_gawk() {
    prep_build gawk-5.3.1.tar.xz 
    pushd $CUR_BUILD_PATH

	sed -i 's/extras//' Makefile.in

	./configure --prefix=/usr   \
            --host=$PLX_TGT \
            --build=$(build-aux/config.guess)

	build_cross_destdir

	popd
}

build_cross_grep() {
    prep_build grep-3.11.tar.xz 
    pushd $CUR_BUILD_PATH

	./configure --prefix=/usr   \
            --host=$PLX_TGT \
            --build=$(./build-aux/config.guess)

	build_cross_destdir

	popd
}


build_cross_gzip() {
    prep_build gzip-1.13.tar.xz 
    pushd $CUR_BUILD_PATH

	./configure --prefix=/usr --host=$PLX_TGT

	build_cross_destdir

	popd
}

build_cross_make() {
    prep_build make-4.4.1.tar.gz 
    pushd $CUR_BUILD_PATH

	./configure --prefix=/usr   \
            --without-guile \
            --host=$PLX_TGT \
            --build=$(build-aux/config.guess)

	build_cross_destdir

	popd
}

build_cross_patch() {
    prep_build patch-2.7.6.tar.xz 
    pushd $CUR_BUILD_PATH

    ./configure --prefix=/usr   \
        --host=$PLX_TGT \
        --build=$(build-aux/config.guess)

    build_cross_destdir

    popd
}

build_cross_sed() {
    prep_build sed-4.9.tar.xz 
    pushd $CUR_BUILD_PATH

        ./configure --prefix=/usr   \
            --host=$PLX_TGT \
            --build=$(build-aux/config.guess)

        build_cross_destdir

	popd
}

build_cross_tar() {
    prep_build tar-1.35.tar.gz 
    pushd $CUR_BUILD_PATH

    ./configure --prefix=/usr   \
        --host=$PLX_TGT \
        --build=$(build-aux/config.guess)

    build_cross_destdir

    popd
}

build_cross_xz() {
    prep_build xz-5.6.4.tar.xz 
    pushd $CUR_BUILD_PATH

    ./configure --prefix=/usr   \
        --host=$PLX_TGT \
    --disable-static --docdir=/usr/share/doc/xz-5.6.4 \
        --build=$(build-aux/config.guess)

    build_cross_destdir

    rm -v $PLX/usr/lib/liblzma.la

    popd
}

build_cross_binutils_p2() {
    prep_build binutils-2.44.tar.xz 
    pushd $CUR_BUILD_PATH

	rm -rf build
	sed '6031s/$add_dir//' -i ltmain.sh

	mkdir build && cd build

	../configure                   \
	    --prefix=/usr              \
	    --build=$(../config.guess) \
	    --host=$PLX_TGT            \
	    --disable-nls              \
	    --enable-shared            \
	    --enable-gprofng=no        \
	    --disable-werror           \
	    --enable-64-bit-bfd        \
	    --enable-new-dtags         \
	    --enable-default-hash-style=gnu

	build_cross_destdir

	rm -v $PLX/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}

	popd
}

build_cross_gcc_p2() {
    prep_build gcc-14.2.0.tar.xz 
    pushd $CUR_BUILD_PATH

	tar -xf $SOURCES_DIR/mpfr-4.2.1.tar.xz
	mv -v mpfr-4.2.1 mpfr
	tar -xf $SOURCES_DIR/gmp-6.3.0.tar.xz
	mv -v gmp-6.3.0 gmp
	tar -xf $SOURCES_DIR/mpc-1.3.1.tar.gz
	mv -v mpc-1.3.1 mpc

	sed -e '/m64=/s/lib64/lib/' \
 	       -i.orig gcc/config/i386/t-linux64

	sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    		-i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

	rm -rf build

	mkdir build && cd build

	../configure                                       \
	    --build=$(../config.guess)                     \
	    --host=$PLX_TGT                                \
	    --target=$PLX_TGT                              \
	    LDFLAGS_FOR_TARGET=-L$PWD/$PLX_TGT/libgcc      \
	    --prefix=/usr                                  \
	    --with-build-sysroot=$PLX                      \
	    --enable-default-pie                           \
	    --enable-default-ssp                           \
	    --disable-nls                                  \
	    --disable-multilib                             \
	    --disable-libatomic                            \
	    --disable-libgomp                              \
	    --disable-libquadmath                          \
	    --disable-libsanitizer                         \
	    --disable-libssp                               \
	    --disable-libvtv                               \
	    --enable-languages=c,c++

	build_cross_destdir

	ln -sv gcc $PLX/usr/bin/cc

	popd
}

plx_prep_virt() {
	sudo chown -R root:root $PLX/{usr,lib,var,etc,bin,sbin,tools,lib64}
	sudo mkdir -pv $PLX/{dev,proc,sys,run}
	sudo mkdir -pv $PLX/usr/share/plx/{bin,tmp,src}
}

run_in_chroot() {
    script=$1
    func=$2
	func_param=""

	sudo cp $SRC_DIR/$script ${PLX:?}/usr/share/plx/tmp/

	sudo mkdir -p $PLX/usr/share/plx/tmp/inst

	sudo touch $PLX/usr/share/plx/tmp/prep.sh

	sudo cp $SRC_DIR/env.sh $PLX/usr/share/plx/bin/

	if [[ -n "${3:-}" ]]; then
		func_param="$3"
		echo "RIC: Param: $func_param"
	fi

	echo "Running chroot: $script - $func - $func_param"

	sudo chroot "$PLX" /usr/bin/env -i   \
	    HOME=/root                  \
	    TERM="$TERM"                \
	    PS1='(lfs chroot) \u:\w\$ ' \
	    PATH=/usr/bin:/usr/sbin     \
	    MAKEFLAGS="-j$(nproc)"      \
	    TESTSUITEFLAGS="-j$(nproc)" \
	    /bin/bash --login -c -e "cd /usr/share/plx/tmp/ && \
            . /usr/share/plx/bin/env.sh && . /usr/share/plx/tmp/prep.sh && \
            . /usr/share/plx/tmp/$script && $func $func_param"

	sudo rm ${PLX:?}/usr/share/plx/tmp/$script
}

plx_prep_release_build() {
    source=$1

    plx_download_source $source sources
    SP=$(plx_get_source_path sources/$source)

	sudo cp sources/$source $PLX/usr/share/plx/tmp/

	pushd $PLX/usr/share/plx/tmp/	
	sudo tar -xf $source
	sudo rm $source
	popd

	echo "cd $SP" | sudo tee $PLX/usr/share/plx/tmp/prep.sh > /dev/null
}

plx_fs_setup() {
	run_in_chroot chr-steps.sh fs_setup
}

plx_create_init_config() {
	run_in_chroot chr-steps.sh create_init_config
}

plx_build_gettext() {
	plx_prep_release_build "gettext-0.24.tar.xz"
	run_in_chroot chr-steps.sh "build_gettext"
}

plx_build_bison() {
	plx_prep_release_build bison-3.8.2.tar.xz
    run_in_chroot chr-steps.sh build_bison
}

plx_build_perl() {
	plx_prep_release_build perl-5.40.1.tar.xz
    run_in_chroot chr-steps.sh build_perl
}

plx_build_python() {
    plx_prep_release_build Python-3.13.2.tar.xz
    run_in_chroot chr-steps.sh build_python
}

plx_build_texinfo() {
    plx_prep_release_build texinfo-7.2.tar.xz
    run_in_chroot chr-steps.sh build_texinfo
}

plx_build_utillinux() {
    plx_prep_release_build util-linux-2.40.4.tar.xz
    run_in_chroot chr-steps.sh build_utillinux
}

plx_cross_cleanup() {
	sudo rm -rf ${PLX:?}/usr/share/{info,man,doc}/*
	sudo find $PLX/usr/{lib,libexec} -name \*.la -delete
	sudo rm -rf $PLX/tools
}

plx_cross_backup() {
    mkdir -p $BACKUP_DIR/
	sudo tar -cJpf $BACKUP_DIR/plx-temp-tools.txz -C ${PLX:?}/ .
}
