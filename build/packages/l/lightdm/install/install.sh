groupadd -g 65 lightdm       || true
useradd  -c "Lightdm Daemon" \
         -d /var/lib/lightdm \
         -u 65 -g lightdm    \
         -s /bin/false lightdm || true


install -v -dm755 -o lightdm -g lightdm /var/lib/lightdm      
install -v -dm755 -o lightdm -g lightdm /var/lib/lightdm-data 
install -v -dm755 -o lightdm -g lightdm /var/cache/lightdm    
install -v -dm770 -o lightdm -g lightdm /var/log/lightdm

install -m 644 lightdm.service /usr/lib/systemd/system/

systemctl enable lightdm
