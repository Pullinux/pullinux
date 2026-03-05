install -v -g sys -m700 -d /var/lib/sshd 

groupadd -g 50 sshd        || true
useradd  -c 'sshd PrivSep' \
         -d /var/lib/sshd  \
         -g sshd           \
         -s /bin/false     \
         -u 50 sshd || true

sed 's@d/login@d/sshd@g' /etc/pam.d/login > /etc/pam.d/sshd

chmod 644 /etc/pam.d/sshd 

echo "UsePAM yes" >> /etc/ssh/sshd_config

UNITSDIR=/usr/lib/systemd/system
CONFMODE=644

install -m ${CONFMODE} sshd.service ${UNITSDIR}/
install -m ${CONFMODE} sshdat.service ${UNITSDIR}/sshd@.service
install -m ${CONFMODE} sshd.socket ${UNITSDIR}/
systemctl enable sshd.service

