groupadd -fg 27 polkitd || true

useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 \
        -g polkitd -s /bin/false polkitd || true


cat > /etc/pam.d/polkit-1 << "EOF"
auth     sufficient pam_unix.so
account  required   pam_unix.so
session  required   pam_env.so
session  required   pam_limits.so
EOF
