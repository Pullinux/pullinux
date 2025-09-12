
make mrproper

cp $PCKBASE/files/config .config

make

make INSTALL_MOD_PATH=$PCKDIR modules_install

mkdir -p $PCKDIR/boot

cp -iv arch/x86/boot/bzImage $PCKDIR/boot/vmlinuz-6.13.4-plx-1.1-systemd
cp -iv .config $PCKDIR/boot/config-6.13.4

make clean

cd ..
mkdir -p $PCKDIR/usr/src
cp -r linux-6.13.4 $PCKDIR/usr/src/

