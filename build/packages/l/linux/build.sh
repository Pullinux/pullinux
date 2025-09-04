
make mrproper

cp $PCKBASE/files/config .config

make

make INSTALL_MOD_PATH=$PCKDIR modules_install

mkdir -p $PCKDIR/boot

cp -iv arch/x86/boot/bzImage $PCKDIR/boot/vmlinuz-6.16.1-plx-1.1-systemd
cp -iv .config $PCKDIR/boot/config-6.16.1

make clean

cd ..
mkdir -p $PCKDIR/usr/src
cp -r linux-6.16.1 $PCKDIR/usr/src/

