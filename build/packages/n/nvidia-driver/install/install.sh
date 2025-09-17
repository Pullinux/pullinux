export TERM=xterm-256color

for service in nvidia-{resume,hibernate,suspend}; do
  systemctl enable $service
done

cat > /etc/systemd/system/nvidia-persistence.service << EOF
[Unit]
Description=NVIDIA Persistence Mode
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -pm 1
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

EOF

systemctl enable nvidia-persistence.service


mkdir -pv /usr/lib/modprobe.d

cat > /usr/lib/modprobe.d/nouveau.conf << "EOF"
# Begin /usr/lib/modprobe.d/nouveau.conf

blacklist nouveau
blacklist nvidiafb
blacklist nova_core
blacklist nova_drm

# End /usr/lib/modprobe.d/nouveau.conf
EOF

cat > /usr/lib/modprobe.d/nvidia_drm.conf << "EOF"
# Begin /usr/lib/modprobe.d/nvidia_drm.conf

options nvidia_drm modeset=1

# End /usr/lib/modprobe.d/nvidia_drm.conf
EOF

cat > /usr/lib/modprobe.d/nvidia.conf << "EOF"
# Begin /usr/lib/modprobe.d/nvidia.conf

options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp

# End /usr/lib/modprobe.d/nvidia.conf
EOF

cat > /usr/lib/pkgconfig/dri.pc << "EOF"
prefix=/usr
includedir=${prefix}/include

dridriverdir=/usr/lib/dri

Name: dri
Description: Direct Rendering Infrastructure
Version: 580.76.05
Requires.private: libdrm >=  2.4.109
Cflags: -I${includedir}
EOF