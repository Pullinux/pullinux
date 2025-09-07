# Setup xsessions (X11 sessions)
install -dvm 755 /usr/share/xsessions
cd /usr/share/xsessions

[ -e plasma.desktop ] ||
ln -sfv $KF6_PREFIX/share/xsessions/plasmax11.desktop 

# Setup wayland-sessions 
install -dvm 755 /usr/share/wayland-sessions
cd /usr/share/wayland-sessions

[ -e plasmawayland.desktop ] ||
ln -sfv $KF6_PREFIX/share/wayland-sessions/plasma.desktop

# Setup xdg-desktop-portal
install -dvm 755 /usr/share/xdg-desktop-portal
cd /usr/share/xdg-desktop-portal 

[ -e kde-portals.conf ] ||
ln -sfv $KF6_PREFIX/share/xdg-desktop-portal/kde-portals.conf

# Setup kde portal
install -dvm 755 /usr/share/xdg-desktop-portal/portals
cd /usr/share/xdg-desktop-portal/portals

[ -e kde.portal ] ||
ln -sfv $KF6_PREFIX/share/xdg-desktop-portal/portals/kde.portal


cat > /etc/pam.d/kde << "EOF"
# Begin /etc/pam.d/kde

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     include        system-auth

account  include        system-account
password include        system-password
session  include        system-session

# End /etc/pam.d/kde
EOF

cat > /etc/pam.d/kde-np << "EOF"
# Begin /etc/pam.d/kde-np

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     required       pam_permit.so

account  include        system-account
password include        system-password
session  include        system-session

# End /etc/pam.d/kde-np
EOF

cat > /etc/pam.d/kscreensaver << "EOF"
# Begin /etc/pam.d/kscreensaver

auth    include system-auth
account include system-account

# End /etc/pam.d/kscreensaver
EOF

copyall() {
    src=$1
    dst=$2

    pushd $src

    for d in $(find . -type d)
    do
        mkdir -p $dst/$d
    done;

    for f in $(find . -type f)
    do
        mv $f $dst/$f
    done;
}

copyall /opt/kf6/etc/dbus-1 /etc/dbus-1
copyall /opt/kf6/share/dbus-1 /usr/share/dbus-1
copyall /opt/kf6/share/polkit-1 /usr/share/polkit-1
copyall /opt/kf6/lib/systemd /usr/lib/systemd

rm -rf /opt/kf6/etc/dbus-1
rm -rf /opt/kf6/share/dbus-1
rm -rf /opt/kf6/share/polkit-1
rm -rf /opt/kf6/lib/systemd

ln -sfv /etc/dbus-1         /opt/kf6/etc/
ln -sfv /usr/share/dbus-1   /opt/kf6/share/   
ln -sfv /usr/share/polkit-1 /opt/kf6/share/   
ln -sfv /usr/lib/systemd    /opt/kf6/lib/
