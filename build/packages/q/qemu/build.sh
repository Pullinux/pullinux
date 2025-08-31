
mkdir -vp build 
cd        build 

../configure --prefix=/usr               \
             --sysconfdir=/etc           \
             --localstatedir=/var        \
             --target-list=x86_64-softmmu,aarch64-softmmu,arm-softmmu,i386-softmmu    \
             --audio-drv-list=alsa       \
             --disable-pa                \
             --enable-slirp              \
             --docdir=/usr/share/doc/qemu-9.2.2 

unset QEMU_ARCH 

make

make DESTDIR=$PCKDIR install

