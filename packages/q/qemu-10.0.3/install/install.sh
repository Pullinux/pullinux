chgrp kvm  /usr/libexec/qemu-bridge-helper
chmod 4750 /usr/libexec/qemu-bridge-helper

cat >> /etc/sysctl.d/60-net-forward.conf << EOF
net.ipv4.ip_forward=1
EOF

install -vdm 755 /etc/qemu
echo allow br0 > /etc/qemu/bridge.conf
