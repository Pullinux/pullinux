for service in nvidia-{resume,hibernate,suspend}; do
  systemctl enable $service
done


mkdir -pv /usr/lib/udev/rules.d &&
cat > /usr/lib/udev/rules.d/60-nvidia.rules << "EOF"
# Always create NVIDIA device nodes at boot time.
ACTION=="add|bind",                \
  ATTR{vendor}=="0x10de",          \
  ATTR{class}=="0x03[0-9]*",       \
  DRIVER=="nvidia",                \
  TEST!="/dev/nvidiactl",          \
  RUN+="/usr/bin/nvidia-modprobe", \
  RUN+="/usr/bin/nvidia-modprobe -c0 -u"
EOF

mkdir -pv /usr/lib/modprobe.d &&
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

depmod -a 6.18.10
