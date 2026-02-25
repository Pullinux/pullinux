
make mrproper

cp ../../config .config

make

make INSTALL_MOD_PATH=$PCKDIR modules_install

mkdir -p $PCKDIR/boot

cp -iv arch/x86/boot/bzImage $PCKDIR/boot/vmlinuz-6.18.10-plx-3.0
cp -iv .config $PCKDIR/boot/config-6.18.0

install -v -m755 -d $PCKDIR/etc/modprobe.d
cat > $PCKDIR/etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

cd ..
mkdir -p $PCKDIR/usr/src
cp -r linux-6.18.10 $PCKDIR/usr/src/

rm $PCKDIR/lib/modules/6.18.10/build

ln -sfv /usr/src/linux-6.18.10 $PCKDIR/lib/modules/6.18.10/build

