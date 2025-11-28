groupadd -g 64 sddm || true
useradd  -c "sddm Daemon" \
         -d /var/lib/sddm \
         -u 64 -g sddm    \
         -s /bin/false sddm || true

install -v -dm755 -o sddm -g sddm /var/lib/sddm

mkdir -p /etc/sddm.conf.d

cat > /etc/sddm.conf.d/kde_settings.conf << EOF
[Autologin]
Relogin=false
Session=
User=

[General]
HaltCommand=
RebootCommand=

[Theme]
Current=Noir-SDDM-6
CursorTheme=Oxygen_Zion
Font=Noto Sans,10,-1,0,400,0,0,0,0,0,0,0,0,0,0,1

[Users]
MaximumUid=60000
MinimumUid=1000

EOF


cat > /etc/sddm.conf << EOF
[General]
DisplayServer=x11
GreeterEnvironment=QML2_IMPORT_PATH=/opt/kf6/lib/qml:/opt/qt6/qml:/opt/qt6/lib/qml:/opt/qt6/qml,QT_PLUGIN_PATH=/opt/kf6/lib/plugins:/opt/kf6/lib/plugins/kcms:/opt/qt6/lib/plugins:/usr/lib/plugins:/opt/qt6/plugins
InputMethod=
Namespaces=
Numlock=none

[Theme]
DisableAvatarsThreshold=7
EnableAvatars=true
FacesDir=/usr/share/sddm/faces
ThemeDir=/usr/share/sddm/themes

[Users]
DefaultPath=/usr/local/bin:/usr/bin:/bin
HideShells=
HideUsers=
RememberLastSession=true
RememberLastUser=true
ReuseSession=true

[Wayland]
CompositorCommand=weston --shell=kiosk
EnableHiDPI=true
SessionCommand=/usr/share/sddm/scripts/wayland-session
SessionDir=/usr/local/share/wayland-sessions,/usr/share/wayland-sessions
SessionLogFile=.local/share/sddm/wayland-session.log

[X11]
DisplayCommand=/usr/share/sddm/scripts/Xsetup
DisplayStopCommand=/usr/share/sddm/scripts/Xstop
EnableHiDPI=true
ServerArguments=-nolisten tcp
ServerPath=/usr/bin/X
SessionCommand=/usr/share/sddm/scripts/Xsession
SessionDir=/usr/local/share/xsessions,/usr/share/xsessions
SessionLogFile=.local/share/sddm/xorg-session.log
XephyrPath=/usr/bin/Xephyr

EOF


systemctl enable sddm

cat > /etc/pam.d/sddm << "EOF" &&
# Begin /etc/pam.d/sddm

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     include        system-auth

account  include        system-account
password include        system-password

session  required       pam_limits.so
session  include        system-session

# End /etc/pam.d/sddm
EOF

cat > /etc/pam.d/sddm-autologin << "EOF" &&
# Begin /etc/pam.d/sddm-autologin

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     required       pam_permit.so

account  include        system-account

password required       pam_deny.so

session  required       pam_limits.so
session  include        system-session

# End /etc/pam.d/sddm-autologin
EOF

cat > /etc/pam.d/sddm-greeter << "EOF"
# Begin /etc/pam.d/sddm-greeter

auth     required       pam_env.so
auth     required       pam_permit.so

account  required       pam_permit.so
password required       pam_deny.so
session  required       pam_unix.so
-session optional       pam_systemd.so

# End /etc/pam.d/sddm-greeter
EOF
