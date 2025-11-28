
groupadd -g 65 lightdm       || true
useradd  -c "Lightdm Daemon" \
         -d /var/lib/lightdm \
         -u 65 -g lightdm    \
         -s /bin/false lightdm || true

./configure --prefix=/usr                 \
            --libexecdir=/usr/lib/lightdm \
            --localstatedir=/var          \
            --sbindir=/usr/bin            \
            --sysconfdir=/etc             \
            --disable-static              \
            --disable-tests               \
            --with-greeter-user=lightdm   \
            --with-greeter-session=lightdm-gtk-greeter \
            --docdir=/usr/share/doc/lightdm-1.32.0 

make

make DESTDIR=$PCKDIR install

mkdir -p $PCKDIR/usr/bin

cp tests/src/lightdm-session $PCKDIR/usr/bin                     
sed -i '1 s/sh/bash --login/' $PCKDIR/usr/bin/lightdm-session        
rm -rf $PCKDIR/etc/init                                  
