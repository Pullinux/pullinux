#!/bin/bash

cat >> make-ca << "EOF"
ln -svf /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
EOF

sed '/mktemp/s/-t //' -i make-ca

make DESTDIR=$PCKDIR install

mkdir -p $PCKDIR/etc/ssl

install -vdm755 $PCKDIR/etc/ssl/local
