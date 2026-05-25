
echo "Finishing Install..."

echo "Setting root password..."

passwd

read -r -p "Enter user name to create: " usrname

useradd -m $usrname

passwd $usrname


read -r -p "Enter UUID of root mount: " rootuuid


cat > /etc/fstab << EOF
# Begin /etc/fstab

UUID=$rootuuid     /        ext4    defaults      1     1

# End /etc/fstab
EOF

