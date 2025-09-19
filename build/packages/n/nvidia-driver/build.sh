export TERM=xterm-256color

sh $PCKBASE/files/NVIDIA-Linux-x86_64-580.76.05.run -x
cd NVIDIA-Linux-x86_64-580.76.05

cd kernel-open

rm -f /lib/modules/6.13.4/build
ln -s /usr/src/linux-6.13.4 /lib/modules/6.13.4/build

make KERNEL_UNAME=6.13.4 NV_EXCLUDE_KERNEL_MODULES=
make KERNEL_UNAME=6.13.4 INSTALL_MOD_PATH=$PCKDIR modules_install

cd ..

rm -rvf $PCKDIR/usr/lib/firmware/nvidia/[0-9]* 
mkdir -pv $PCKDIR/usr/lib/firmware/nvidia/580.76.05 
cp -v firmware/*.bin $PCKDIR/usr/lib/firmware/nvidia/580.76.05

mkdir -p $PCKDIR/usr/bin
mkdir -p $PCKDIR/usr/sbin

rm -rf $PCKDIR/usr/sbin/nvidia-install

mkdir -pv $PCKDIR/usr/share/nvidia              
install -vm755 $PCKBASE/files/install-NVIDIA-1        \
               $PCKDIR/usr/sbin/nvidia-install  
install -vm644 $PCKBASE/files/manifest-NVIDIA-1       \
               $PCKDIR/usr/share/nvidia/manifest

mkdir -pv /usr/share/nvidia
install -vm644 $PCKBASE/files/manifest-NVIDIA-1       \
               /usr/share/nvidia/manifest

$PCKDIR/usr/sbin/nvidia-install --destdir=$PCKDIR

mkdir -pv $PCKDIR/usr/lib/systemd/system             \
          $PCKDIR/usr/lib/systemd/system-sleep       \
          $PCKDIR/usr/share/dbus-1/system.d         
install -vm755 nvidia-powerd $PCKDIR/usr/bin        
install -vm755 systemd/nvidia-sleep.sh $PCKDIR/usr/bin                      
install -vm755 systemd/system-sleep/nvidia $PCKDIR/usr/lib/systemd/system-sleep 

cp -v systemd/system/*.service                \
      $PCKDIR/usr/lib/systemd/system                
cp -v nvidia-dbus.conf                        \
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
