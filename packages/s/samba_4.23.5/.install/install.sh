DEFAULTSDIR=/etc/default
TMPFILESDIR=/usr/lib/tmpfiles.d
UNITSDIR=/usr/lib/systemd/system
CONFMODE=644

install -m ${CONFMODE} default/samba ${DEFAULTSDIR}/
install -m ${CONFMODE} tmpfiles/samba.conf ${TMPFILESDIR}/
install -m ${CONFMODE} units/nmbd.service ${UNITSDIR}/
install -m ${CONFMODE} units/samba.service ${UNITSDIR}/
install -m ${CONFMODE} units/smbd.service ${UNITSDIR}/
install -m ${CONFMODE} units/smbdat.service ${UNITSDIR}/smbd@.service
install -m ${CONFMODE} units/smbd.socket ${UNITSDIR}/
systemd-tmpfiles --create samba.conf
systemctl enable nmbd.service
systemctl enable smbd.service

