cat > /etc/ld.so.conf.d/cuda.conf << EOF &&
/opt/cuda/lib64
/opt/cuda/nvvm/lib64
/opt/cuda/extras/CUPTI/lib64
EOF

ldconfig

cat > /etc/profile.d/cuda.sh << "EOF"
# Begin /etc/profile.d/cuda.sh

pathprepend /opt/cuda/bin           PATH

# End /etc/profile.d/cuda.sh
EOF

