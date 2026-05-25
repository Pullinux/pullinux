#!/bin/bash

install -v -g sys -m700 -d /var/lib/sshd 

groupadd -g 50 sshd        || true
useradd  -c 'sshd PrivSep' \
         -d /var/lib/sshd  \
         -g sshd           \
         -s /bin/false     \
         -u 50 sshd || true

./configure --prefix=/usr                            \
            --sysconfdir=/etc/ssh                    \
            --with-privsep-path=/var/lib/sshd        \
            --with-default-path=/usr/bin             \
            --with-superuser-path=/usr/sbin:/usr/bin \
            --with-pid-dir=/run   --with-pam

make
make DESTDIR=$PCKDIR install

mkdir -p $PCKDIR/usr/bin

install -v -m755    contrib/ssh-copy-id $PCKDIR/usr/bin/
