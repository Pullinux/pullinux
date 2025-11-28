cat >> make-ca << "EOF"
ln -svf /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
EOF

make DESTDIR=$PCKDIR install
install -vdm755 $PCKDIR/etc/ssl/local


