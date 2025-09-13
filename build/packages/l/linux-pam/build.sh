
mkdir __build && cd __build
meson setup --prefix=/usr --buildtype=release -D docdir=/usr/share/doc/Linux-PAM-1.7.1 ..
ninja

install -v -m755 -d $PCKDIR/etc/pam.d

DESTDIR=$PCKDIR ninja install

chmod -v 4755 $PCKDIR/usr/sbin/unix_chkpwd

#32bit
mkdir -p $PCKDIR/usr/lib32

rm -rf * 
CC="gcc -m32" CXX="g++ -m32"           \
PKG_CONFIG_PATH="/usr/lib32/pkgconfig" \
meson setup ..                         \
  --prefix=/usr                        \
  --libdir=/usr/lib32                  \
  --buildtype=release                  \
  -D docs=disabled 

ninja
DESTDIR=$PWD/DESTDIR ninja install  
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
ldconfig


cat > $PCKDIR/etc/pam.d/system-account << "EOF" &&
# Begin /etc/pam.d/system-account

account   required    pam_unix.so

# End /etc/pam.d/system-account
EOF

cat > $PCKDIR/etc/pam.d/system-auth << "EOF" &&
# Begin /etc/pam.d/system-auth

auth      required    pam_unix.so

# End /etc/pam.d/system-auth
EOF

cat > $PCKDIR/etc/pam.d/system-session << "EOF" &&
# Begin /etc/pam.d/system-session

session   required    pam_unix.so

# End /etc/pam.d/system-session
EOF

cat > $PCKDIR/etc/pam.d/system-password << "EOF"
# Begin /etc/pam.d/system-password

# use yescrypt hash for encryption, use shadow, and try to use any
# previously defined authentication token (chosen password) set by any
# prior module.
password  required    pam_unix.so       yescrypt shadow try_first_pass

# End /etc/pam.d/system-password
EOF

cat > $PCKDIR/etc/pam.d/other << "EOF"
# Begin /etc/pam.d/other

auth        required        pam_warn.so
auth        required        pam_deny.so
account     required        pam_warn.so
account     required        pam_deny.so
password    required        pam_warn.so
password    required        pam_deny.so
session     required        pam_warn.so
session     required        pam_deny.so

# End /etc/pam.d/other
EOF


