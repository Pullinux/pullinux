patch -Np1 -i $PCKBASE/files/qemu-10.0.3-python_fixes-1.patch

mkdir -vp build 
cd        build 

../configure --prefix=/usr            \
             --sysconfdir=/etc        \
             --localstatedir=/var     \
             --target-list=x86_64-softmmu,aarch64-softmmu,arm-softmmu,i386-softmmu \
             --audio-drv-list=alsa    \
             --disable-pa             \
             --enable-slirp           \
             --docdir=/usr/share/doc/qemu-10.0.3 

make

make DESTDIR=$PCKDIR install

