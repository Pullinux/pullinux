wget -c https://us.download.nvidia.com/XFree86/Linux-x86_64/590.48.01/NVIDIA-Linux-x86_64-590.48.01.run

wget https://www.linuxfromscratch.org/glfs/view/dev/download/NVIDIA/install-NVIDIA-2

wget https://www.linuxfromscratch.org/glfs/view/dev/download/NVIDIA/manifest-NVIDIA-2

sh NVIDIA-Linux-x86_64-590.48.01.run -x
cd NVIDIA-Linux-x86_64-590.48.01

cd kernel-open

export KERNEL_UNAME=6.18.10

make NV_EXCLUDE_KERNEL_MODULES=

mkdir -p $PCKDIR/lib/modules/$KERNEL_UNAME/kernel/drivers/video/

make DESTDIR=$PCKDIR modules_install

make modules_install

cp -r /lib/modules/$KERNEL_UNAME/kernel/drivers/video/nvidia* $PCKDIR/lib/modules/$KERNEL_UNAME/kernel/drivers/video/

cd ..

unset KERNEL_UNAME

mkdir -pv $PCKDIR/usr/lib/firmware/nvidia/590.48.01
cp -v firmware/*.bin $PCKDIR/usr/lib/firmware/nvidia/590.48.01

mkdir -p $PCKDIR/usr/sbin/

install -vdm755 $PCKDIR/usr/share/nvidia
install -vDm755 ../install-NVIDIA-2 $PCKDIR/usr/sbin/nvidia-install
install -vDm644 ../manifest-NVIDIA-2 $PCKDIR/usr/share/nvidia/manifest

#$PCKDIR/usr/sbin/nvidia-install

mkdir -p $PCKDIR/usr/lib
mkdir -p $PCKDIR/usr/lib32
mkdir -p $PCKDIR/usr/bin
mkdir -p $PCKDIR/usr/share
mkdir -p $PCKDIR/etc

$PCKDIR/usr/sbin/nvidia-install --destdir=$PCKDIR --prefix=/usr --ex-run-dir=$(pwd)

mkdir -pv $PCKDIR/usr/lib/systemd/system               \
          $PCKDIR/usr/lib/systemd/system-sleep         \
          $PCKDIR/usr/share/dbus-1/system.d           
mkdir -p $PCKDIR/usr/bin/

install -vDm755 nvidia-powerd -t $PCKDIR/usr/bin/     
install -vDm755 systemd/nvidia-sleep.sh         \
             -t $PCKDIR/usr/bin/                      
install -vDm755 systemd/system-sleep/nvidia     \
             -t $PCKDIR/usr/lib/systemd/system-sleep/ 
cp -v systemd/system/*.service                  \
      $PCKDIR/usr/lib/systemd/system                  
cp -v nvidia-dbus.conf                          \
      $PCKDIR/usr/share/dbus-1/system.d               

cat > systemd-homed-override.conf << "EOF" 
[Service]
Environment="SYSTEMD_HOME_LOCK_FREEZE_SESSION=false"
EOF

cat > systemd-suspend-override.conf << "EOF" 
[Service]
Environment="SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false"
EOF

for service in {homed,suspend,suspend-then-hibernate,hibernate,hybrid-sleep}; do
  mkdir -pv $PCKDIR/usr/lib/systemd/system/systemd-"$service".service.d
done

cp -v systemd-homed-override.conf                                                       \
      $PCKDIR/usr/lib/systemd/system/systemd-homed.service.d/10-nvidia-no-freeze-session.conf

for service in {suspend,suspend-then-hibernate,hibernate,hybrid-sleep}; do
  cp -v systemd-suspend-override.conf \
    $PCKDIR/usr/lib/systemd/system/systemd-"$service".service.d/10-nvidia-no-freeze-session.conf
done

