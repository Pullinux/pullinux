systemctl enable update-pki.timer
$PCKDIR/usr/sbin/make-ca -g --force

cat > /etc/profile.d/pythoncerts.sh << "EOF"
# Begin /etc/profile.d/pythoncerts.sh

export _PIP_STANDALONE_CERT=/etc/pki/tls/certs/ca-bundle.crt

# End /etc/profile.d/pythoncerts.sh
EOF