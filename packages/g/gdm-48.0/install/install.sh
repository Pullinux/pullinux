groupadd -g 21 gdm || true
useradd -c "GDM Daemon Owner" -d /var/lib/gdm -u 21 \
        -g gdm -s /bin/false gdm || true
passwd -ql gdm || true

ln -s /dev/null /etc/udev/rules.d/61-gdm.rules

systemctl enable gdm

mkdir -p /var/lib/gdm/.config/dconf
chown gdm:gdm -R /var/lib/gdm

install -d -m 700 -o gdm -g gdm /run/user/21


sudo -u gdm XDG_RUNTIME_DIR=/run/user/21 dbus-run-session --  \
             gsettings set org.gnome.settings-daemon.plugins.power \
                           sleep-inactive-ac-type                  \
                           "nothing"

cat > /etc/pam.d/gdm-launch-environment << EOF
auth     required  pam_env.so
auth     required  pam_permit.so
account  required  pam_permit.so
password required  pam_deny.so

session  required  pam_limits.so
session  required  pam_unix.so
session  optional  pam_systemd.so

EOF

cat > /etc/pam.d/gdm-password << EOF
auth     include   system-auth
account  include   system-account
password include   system-auth
session  include   system-session
EOF

glib-compile-schemas /usr/share/glib-2.0/schemas

gtk-update-icon-cache -qtf /usr/share/icons/hicolor
update-desktop-database -q
