groupadd -g 21 gdm || true
useradd -c "GDM Daemon Owner" -d /var/lib/gdm -u 21 \
        -g gdm -s /bin/false gdm || true

passwd -ql gdm || true

systemctl enable gdm