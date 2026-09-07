
pck_build_pam() {
    mkdir build 
    cd    build

    meson setup --prefix=/usr       \
                --buildtype=release \
                -D docs=disabled    \
                .. 
    ninja
    ninja install 
    chmod -v 4755 /usr/sbin/unix_chkpwd

    rm -rf * 
    meson setup --prefix=/usr       \
                --buildtype=release \
                --cross-file=lib32  \
                -D docs=disabled    \
                ..  
    ninja

    Now, as the root user:

    DESTDIR=$PWD/DESTDIR ninja install    
    cp -vR DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig

install -vdm755 /etc/pam.d &&
cat > /etc/pam.d/system-account << "EOF" &&
# Begin /etc/pam.d/system-account

account   required    pam_unix.so

# End /etc/pam.d/system-account
EOF

cat > /etc/pam.d/system-auth << "EOF" &&
# Begin /etc/pam.d/system-auth

auth      required    pam_unix.so

# End /etc/pam.d/system-auth
EOF

cat > /etc/pam.d/system-session << "EOF" &&
# Begin /etc/pam.d/system-session

session   required    pam_unix.so

# End /etc/pam.d/system-session
EOF

cat > /etc/pam.d/system-password << "EOF"
# Begin /etc/pam.d/system-password

# use yescrypt hash for encryption, use shadow, and try to use any
# previously defined authentication token (chosen password) set by any
# prior module.
password  required    pam_unix.so       yescrypt shadow try_first_pass

# End /etc/pam.d/system-password
EOF

cat > /etc/pam.d/other << "EOF"
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

}

pck_build_shadowpam() {
    find man -name Makefile.in                \
            -exec sed -e 's/getspnam\.3 / /' \
                    -e 's/passwd\.5 / /'   \
                    -i {} \; &&

    sed -e 's@#ENCRYPT_METHOD SHA512@ENCRYPT_METHOD YESCRYPT@' \
        -e 's@/var/spool/mail@/var/mail@'                      \
        -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                     \
        -i etc/login.defs

    ./configure --sysconfdir=/etc   \
                --disable-static    \
                --without-libbsd    \
                --with-{b,yes}crypt &&
    make
    make exec_prefix=/usr pamddir= install
    make -C man install-man

    install -vDm644 /etc/login.defs /etc/login.defs.orig &&
    for FUNCTION in FAIL_DELAY               \
                    FAILLOG_ENAB             \
                    LASTLOG_ENAB             \
                    MAIL_CHECK_ENAB          \
                    OBSCURE_CHECKS_ENAB      \
                    PORTTIME_CHECKS_ENAB     \
                    QUOTAS_ENAB              \
                    CONSOLE MOTD_FILE        \
                    FTMP_FILE NOLOGINS_FILE  \
                    ENV_HZ PASS_MIN_LEN      \
                    SU_WHEEL_ONLY            \
                    CRACKLIB_DICTPATH        \
                    PASS_CHANGE_TRIES        \
                    PASS_ALWAYS_WARN         \
                    CHFN_AUTH ENCRYPT_METHOD \
                    ENVIRON_FILE
    do
        sed -i "s/^${FUNCTION}/# &/" /etc/login.defs
    done

cat > /etc/pam.d/login << "EOF"
# Begin /etc/pam.d/login

# Set failure delay before next prompt to 3 seconds
auth      optional    pam_faildelay.so  delay=3000000

# Check to make sure that the user is allowed to login
auth      requisite   pam_nologin.so

# Check to make sure that root is allowed to login
# Disabled by default. You will need to create /etc/securetty
# file for this module to function. See man 5 securetty.
#auth      required    pam_securetty.so

# Additional group memberships - disabled by default
#auth      optional    pam_group.so

# include system auth settings
auth      include     system-auth

# check access for the user
account   required    pam_access.so

# include system account settings
account   include     system-account

# Set default environment variables for the user
session   required    pam_env.so

# Set resource limits for the user
session   required    pam_limits.so

# Display the message of the day - Disabled by default
#session   optional    pam_motd.so

# Check user's mail - Disabled by default
#session   optional    pam_mail.so      standard quiet

# include system session and password settings
session   include     system-session
password  include     system-password

# End /etc/pam.d/login
EOF

cat > /etc/pam.d/passwd << "EOF"
# Begin /etc/pam.d/passwd

password  include     system-password

# End /etc/pam.d/passwd
EOF


cat > /etc/pam.d/su << "EOF"
# Begin /etc/pam.d/su

# always allow root
auth      sufficient  pam_rootok.so

# Allow users in the wheel group to execute su without a password
# disabled by default
#auth      sufficient  pam_wheel.so trust use_uid

# include system auth settings
auth      include     system-auth

# limit su to users in the wheel group
# disabled by default
#auth      required    pam_wheel.so use_uid

# include system account settings
account   include     system-account

# Set default environment variables for the service user
session   required    pam_env.so

# include system session settings
session   include     system-session

# End /etc/pam.d/su
EOF

cat > /etc/pam.d/chpasswd << "EOF"
# Begin /etc/pam.d/chpasswd

# always allow root
auth      sufficient  pam_rootok.so

# include system auth and account settings
auth      include     system-auth
account   include     system-account
password  include     system-password

# End /etc/pam.d/chpasswd
EOF

sed -e s/chpasswd/newusers/ /etc/pam.d/chpasswd >/etc/pam.d/newusers


cat > /etc/pam.d/chage << "EOF"
# Begin /etc/pam.d/chage

# always allow root
auth      sufficient  pam_rootok.so

# include system auth and account settings
auth      include     system-auth
account   include     system-account

# End /etc/pam.d/chage
EOF

    for PROGRAM in chfn chgpasswd chsh groupadd groupdel \
                groupmems groupmod useradd userdel usermod
    do
        install -vDm644 /etc/pam.d/chage /etc/pam.d/${PROGRAM}
        sed -i "s/chage/$PROGRAM/" /etc/pam.d/${PROGRAM}
    done

    if [ -f /etc/login.access ]; then mv -v /etc/login.access{,.NOUSE}; fi

    if [ -f /etc/limits ]; then mv -v /etc/limits{,.NOUSE}; fi
}

pck_build_systemdpam() {
    sed -i -e 's/GROUP="render"/GROUP="video"/' \
       -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in

    mkdir build 
    cd    build 

    meson setup --prefix=/usr            \
                --buildtype=release      \
                -D default-dnssec=no     \
                -D firstboot=false       \
                -D install-tests=false   \
                -D ldconfig=false        \
                -D man=auto              \
                -D sysusers=false        \
                -D rpmmacrosdir=no       \
                -D homed=disabled        \
                -D mode=release          \
                -D pam=enabled           \
                -D pamconfdir=/etc/pam.d \
                -D dev-kvm-mode=0660     \
                -D nobody-group=nogroup  \
                -D sysupdate=disabled    \
                -D ukify=disabled        \
                -D docdir=/usr/share/doc/systemd-261.2 \
                .. 
    ninja
    ninja install

    rm -rf * 
    LANG=en_US.UTF-8                     \
    meson setup --prefix=/usr            \
                --buildtype=release      \
                --cross-file=lib32       \
                -D default-dnssec=no     \
                -D firstboot=false       \
                -D install-tests=false   \
                -D ldconfig=false        \
                -D man=disabled          \
                -D sysusers=false        \
                -D rpmmacrosdir=no       \
                -D homed=disabled        \
                -D userdb=false          \
                -D mode=release          \
                -D pam=enabled           \
                -D pamconfdir=/etc/pam.d \
                -D nobody-group=nogroup  \
                -D sysupdate=disabled    \
                -D ukify=disabled        \
                .. 

    LANG=en_US.UTF-8 ninja

    LANG=en_US.UTF-8 DESTDIR=$PWD/DESTDIR ninja install          &&
    cp -vR DESTDIR/usr/lib32/security       /usr/lib32           &&
    cp -va DESTDIR/usr/lib32/libsystemd.so* /usr/lib32           &&
    cp -va DESTDIR/usr/lib32/libudev.so*    /usr/lib32           &&
    cp -v  DESTDIR/usr/lib32/pkgconfig/*    /usr/lib32/pkgconfig &&
    rm -rf DESTDIR

    grep 'pam_systemd' /etc/pam.d/system-session ||
cat >> /etc/pam.d/system-session << "EOF"
# Begin Systemd addition

session  required    pam_loginuid.so
session  optional    pam_systemd.so

# End Systemd addition
EOF

cat > /etc/pam.d/systemd-user << "EOF"
# Begin /etc/pam.d/systemd-user

account  required    pam_access.so
account  include     system-account

session  required    pam_env.so
session  required    pam_limits.so
session  required    pam_loginuid.so
session  optional    pam_keyinit.so force revoke
session  optional    pam_systemd.so

auth     required    pam_deny.so
password required    pam_deny.so

# End /etc/pam.d/systemd-user
EOF

install -vDm755 /dev/stdin /etc/systemd/user-environment-generators/50-profile.sh << "EOF"
#!/usr/bin/env -S -i /usr/bin/bash
# SPDX-License-Identifier: MIT

. /etc/profile

# Systemd should have already set a better value for them.
unset XDG_RUNTIME_DIR
for i in $(locale); do
  unset ${i%=*}
done

# Some shell magic that we don't want to expose.
unset SHLVL

# Systemd does not want to pass functions to the environment
for i in $(declare -pF | awk '{print $3}'); do
  unset -f $i
done

python3 << _EOF
import os
for var in os.environ:
  # Simply unsetting them in shell does not work.
  if var in ['LC_CTYPE', '_']:
    continue

  print(var + '=' + os.environ[var])
_EOF
EOF

}

pck_build_duktape() {
    sed -i 's/-Os/-O2/' Makefile.sharedlibrary &&
    make -f Makefile.sharedlibrary INSTALL_PREFIX=/usr

    make -f Makefile.sharedlibrary INSTALL_PREFIX=/usr install
}

pck_build_glib() {
    mkdir build 
    cd    build 

    meson setup --prefix=/usr             \
                --buildtype=release       \
                -D introspection=disabled \
                -D glib_debug=disabled    \
                -D man-pages=disabled     \
                -D tests=false            \
                -D sysprof=disabled       \
                .. 
    ninja
    ninja install

    tar xf /sources/gobject-introspection-1.86.0.tar.xz 

    meson setup gobject-introspection-1.86.0 gi-build \
                --prefix=/usr --buildtype=release     
    ninja -C gi-build

    ninja -C gi-build install

    meson configure -D introspection=enabled 
    ninja
    ninja install

    rm -rf * 
    meson setup --prefix=/usr             \
                --buildtype=release       \
                --cross-file=lib32        \
                -D introspection=disabled \
                -D glib_debug=disabled    \
                -D man-pages=disabled     \
                -D tests=false            \
                -D sysprof=disabled       \
                .. 

    ninja

    DESTDIR=$PWD/DESTDIR ninja install    
    cp -vR DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_shared_mime_info() {
    mkdir build &&
    cd    build 

    meson setup --prefix=/usr         \
                --buildtype=release   \
                -D update-mimedb=true \
                -D build-tests=false  \
                -D build-spec=false   \
                .. 
    ninja

    ninja install

}

pck_build_desktop_file_utils() {
    mkdir build &&
    cd    build 

    meson setup --prefix=/usr --buildtype=release .. 
    ninja

    ninja install
}

pck_build_polkit() {
    groupadd -fg 27 polkitd 
    useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 \
            -g polkitd -s /bin/false polkitd

    mkdir build 
    cd    build 

    meson setup --prefix=/usr                \
                --buildtype=release          \
                -D os_type=lfs               \
                -D man=false                 \
                -D session_tracking=logind   \
                -D tests=false               \
                .. 
    ninja

    ninja install
}

