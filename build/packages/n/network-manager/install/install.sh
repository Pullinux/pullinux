cat >> /etc/NetworkManager/NetworkManager.conf << "EOF"
[main]
plugins=keyfile
EOF

cat > /etc/NetworkManager/conf.d/polkit.conf << "EOF"
[main]
auth-polkit=true
EOF

groupadd -fg 86 netdev || true

cat > /usr/share/polkit-1/rules.d/org.freedesktop.NetworkManager.rules << "EOF"
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.NetworkManager.") == 0 && subject.isInGroup("netdev")) {
        return polkit.Result.YES;
    }
});
EOF

systemctl enable NetworkManager
systemctl disable NetworkManager-wait-online

sudo systemctl stop systemd-networkd.service systemd-networkd.socket systemd-networkd-wait-online.service
sudo systemctl disable systemd-networkd.service systemd-networkd.socket systemd-networkd-wait-online.service

sudo mkdir -p /etc/systemd/network.disabled
sudo mv /etc/systemd/network/*.network /etc/systemd/network.disabled/ 2>/dev/null || true

systemctl start NetworkManager
