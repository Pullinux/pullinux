set -e

echo "Creating live ISO..."


echo "Cleaning previous..."

rm -rf /usr/share/pullinux/liveiso
mkdir -p /usr/share/pullinux/liveiso

cd /usr/share/pullinux/liveiso

cat > /usr/share/pullinux/liveiso/init << "EOF"
#!/bin/sh

# 1. Setup API filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# 2. Create all necessary mount points at once
mkdir -p /mnt/iso /mnt/ro_root /mnt/rw_layer /mnt/merged

# 3. Find and mount the ISO
# We try by label first, then fall back to common device nodes
echo "Searching for PLX_LIVE media..."
mount /dev/disk/by-label/PLX_LIVE /mnt/iso 2>/dev/null || \
mount /dev/sr0 /mnt/iso 2>/dev/null || \
mount /dev/sda /mnt/iso 2>/dev/null || \
mount /dev/sdb /mnt/iso 2>/dev/null

# Replace your mount block with this "Auto-Discovery" loop:
found=0
# Give the kernel 5 seconds to finish hardware discovery
for i in 1 2 3 4 5; do
    echo "Scanning for media (attempt $i)..."
    for dev in /dev/sr* /dev/sd*; do
        [ -e "$dev" ] || continue
        
        # -r for read-only, -t iso9660 to be explicit
        if mount -r -t iso9660 "$dev" /mnt/iso 2>/dev/null || \
           mount -r "$dev" /mnt/iso 2>/dev/null; then
           
            if [ -f /mnt/iso/boot/rootfs.sfs ]; then
                echo "SUCCESS: Found Pullinux system on $dev"
                found=1
                break 2
            fi
            umount /mnt/iso 2>/dev/null
        fi
    done
    echo "Not found yet, waiting..."
    sleep 1
done

if [ "$found" -ne 1 ]; then
    echo "ERROR: Could not find rootfs.sfs on any device!"
    echo "Available partitions:"
    cat /proc/partitions
    /bin/sh
fi

# 4. Mount the compressed SquashFS
mount -t squashfs -o loop /mnt/iso/boot/rootfs.sfs /mnt/ro_root

# 5. Create the Writable Layer in RAM
mount -t tmpfs tmpfs /mnt/rw_layer
mkdir -p /mnt/rw_layer/upper /mnt/rw_layer/work

# 6. Combine them using OverlayFS
mount -t overlay overlay -o lowerdir=/mnt/ro_root,upperdir=/mnt/rw_layer/upper,workdir=/mnt/rw_layer/work /mnt/merged

# 7. Prepare the transition
# We move the ISO mount so the new system can see it (optional but helpful)
mkdir -p /mnt/merged/mnt/iso
mount --move /mnt/iso /mnt/merged/mnt/iso

# 8. Switch to the new system
echo "Booting Pullinux system..."
exec switch_root /mnt/merged /sbin/init

EOF

echo "Creating initramfs..."

INITFILE=/usr/share/pullinux/liveiso/init mkinitramfs 6.18.10

mkdir -p /usr/share/pullinux/liveiso/rootfs

mkdir -p /usr/share/pullinux/liveiso/iso/boot/grub/

echo "Installing base system..."

plx-install base-system -d /usr/share/pullinux/liveiso/rootfs

CHRENV=/usr/share/pullinux/liveiso/rootfs

mountpoint -q $CHRENV/dev/shm && umount $CHRENV/dev/shm
umount $CHRENV/dev/pts
umount $CHRENV/{sys,proc,run,dev}


echo "Copying package data..."

mkdir -p /usr/share/pullinux/liveiso/rootfs/usr/share/pullinux/packages/

shopt -s extglob
cp -ra /usr/share/pullinux/packages/!(bin) /usr/share/pullinux/liveiso/rootfs/usr/share/pullinux/packages/

mkdir -p /usr/share/pullinux/liveiso/rootfs/etc/systemd/system/getty@tty1.service.d

cat > /usr/share/pullinux/liveiso/rootfs/etc/systemd/system/getty@tty1.service.d/override.conf << "EOF"
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I $TERM

EOF

echo "ROOT INFO:"
grep root /usr/share/pullinux/liveiso/rootfs/etc/shadow

sed -i 's/^root:[^:]*:/root::/' /usr/share/pullinux/liveiso/rootfs/etc/shadow

cat > /usr/share/pullinux/liveiso/rootfs/etc/fstab << "EOF"
/dev/root      /             auto    defaults,ro        0      0

# Critical Virtual Filesystems
proc           /proc         proc    nosuid,noexec,nodev 0      0
sysfs          /sys          sysfs   nosuid,noexec,nodev 0      0
devpts         /dev/pts      devpts  gid=5,mode=620      0      0
tmpfs          /run          tmpfs   defaults,nodev,nosuid,mode=0755 0 0
devshm         /dev/shm      tmpfs   nosuid,nodev        0      0

# Writable areas in RAM (Crucial for a functional system)
tmpfs          /tmp          tmpfs   defaults,nosuid,nodev 0      0
tmpfs          /var/log      tmpfs   defaults,nosuid,nodev 0      0
tmpfs          /var/lib/sudo tmpfs   defaults,nosuid,nodev 0      0 (Optional)

EOF

echo "Squashing root file system..."

mksquashfs /usr/share/pullinux/liveiso/rootfs /usr/share/pullinux/liveiso/iso/boot/rootfs.sfs -e boot

echo "Copying boot files..."

mv initrd.img-6.18.10 /usr/share/pullinux/liveiso/iso/boot/
cp /boot/vmlinuz-6.18.10-plx-3.0 /usr/share/pullinux/liveiso/iso/boot/


cat > /usr/share/pullinux/liveiso/iso/boot/grub/grub.cfg << "EOF"
set default=0
set timeout=5

menuentry "Pullinux Live (SquashFS + OverlayFS)" {
    # Load the kernel
    linux /boot/vmlinuz-6.18.10-plx-3.0 root=/dev/ram0 rw earlyprintk loglevel=7 

    # Load the initramfs
    initrd /boot/initrd.img-6.18.10
}

menuentry "Pullinux Live (RAM Mode - Everything to RAM)" {
    linux /boot/vmlinuz-6.18.10-plx-3.0 root=/dev/ram0 rw earlyprintk loglevel=7 copytoram
    initrd /boot/initrd.img-6.18.10
}

EOF

grub-mkrescue -o /usr/share/pullinux/liveiso/pullinux-live.iso /usr/share/pullinux/liveiso/iso/ -- -volid "PLX_LIVE"

echo ""
echo "Live ISO Created: /usr/share/pullinux/liveiso/pullinux-live.iso"
