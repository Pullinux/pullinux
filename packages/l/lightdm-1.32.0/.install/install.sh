groupadd -g 65 lightdm       || true
useradd  -c "Lightdm Daemon" \
         -d /var/lib/lightdm \
         -u 65 -g lightdm    \
         -s /bin/false lightdm || true


install -m 644 lightdm.service /usr/lib/systemd/system/

systemctl enable lightdm
