systemctl enable plasmalogin

groupadd -r plasmalogin || true
useradd -r -g plasmalogin -d /var/lib/plasmalogin -s /sbin/nologin -c "Plasma Login Manager" plasmalogin || true

mkdir -p /usr/lib/plasmalogin
chown plasmalogin:plasmalogin /usr/lib/plasmalogin

cat > /etc/pam.d/plasmalogin << "EOF" &&
# Begin /etc/pam.d/plasmalogin

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     include        system-auth

account  include        system-account
password include        system-password

session  required       pam_limits.so
session  include        system-session

# End /etc/pam.d/plasmalogin
EOF

cat > /etc/pam.d/plasmalogin-autologin << "EOF" &&
# Begin /etc/pam.d/plasmalogin-autologin

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     required       pam_permit.so

account  include        system-account

password required       pam_deny.so

session  required       pam_limits.so
session  include        system-session

# End /etc/pam.d/plasmalogin-autologin
EOF

cat > /etc/pam.d/plasmalogin-greeter << "EOF"
# Begin /etc/pam.d/plasmalogin-greeter

auth     required       pam_env.so
auth     required       pam_permit.so

account  required       pam_permit.so
password required       pam_deny.so
session  required       pam_unix.so
-session optional       pam_systemd.so

# End /etc/pam.d/plasmalogin-greeter
EOF

ln -s /opt/kf6/bin/startplasma-login-wayland /usr/bin/startplasma-login-wayland
