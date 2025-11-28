python3 -m venv --system-site-packages pyvenv         
./pyvenv/bin/pip3 install cryptography pyasn1 iso8601

PYTHON=$PWD/pyvenv/bin/python3             \
./configure                                \
    --prefix=/usr                          \
    --sysconfdir=/etc                      \
    --localstatedir=/var                   \
    --with-piddir=/run/samba               \
    --with-pammodulesdir=/usr/lib/security \
    --enable-fhs                           \
    --without-ad-dc                        \
    --with-system-mitkrb5                  \
    --enable-selftest                      \
    --disable-rpath-install

make

sed '1s@^.*$@#!/usr/bin/python3@' \
    -i ./bin/default/source4/scripting/bin/*.inst

make DESTDIR=$PCKDIR install

mkdir -p $PCKDIR/etc/samba

install -v -m644 examples/smb.conf.default $PCKDIR/etc/samba &&

sed -e "s;log file =.*;log file = /var/log/samba/%m.log;"   \
    -e "s;path = /usr/spool/samba;path = /var/spool/samba;" \
    -i $PCKDIR/etc/samba/smb.conf.default 

mkdir -pv $PCKDIR/etc/openldap/schema 

install -v -m644    examples/LDAP/README \
                    $PCKDIR/etc/openldap/schema/README.samba 

install -v -m644    examples/LDAP/samba* \
                    $PCKDIR/etc/openldap/schema 

install -v -m755    examples/LDAP/{get*,ol*} \
                    $PCKDIR/etc/openldap/schema
