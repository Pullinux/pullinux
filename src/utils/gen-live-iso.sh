set -e

echo "Creating live ISO..."

echo ""
echo "Cleaning previous..."
echo ""

rm -rf /usr/share/pullinux/liveiso
mkdir -p /usr/share/pullinux/liveiso

cd /usr/share/pullinux/liveiso

cat > /usr/share/pullinux/liveiso/init << "EOF"
#!/bin/sh

set -e

# Setup API filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# Create all necessary mount points at once
mkdir -p /mnt/iso /mnt/ro_root /mnt/rw_layer /mnt/merged

# Find and mount the ISO
# We try by label first, then fall back to common device nodes
echo "Searching for PLX_LIVE media..."
mount /dev/disk/by-label/PLX_LIVE /mnt/iso 2>/dev/null || \
mount /dev/sr0 /mnt/iso 2>/dev/null || \
mount /dev/sda /mnt/iso 2>/dev/null || \
mount /dev/sdb /mnt/iso 2>/dev/null

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

echo "Mounting root filesystem..."

# Mount the compressed SquashFS
mount -t squashfs -o loop /mnt/iso/boot/rootfs.sfs /mnt/ro_root

echo "Mounting packages..."

# Mount the package binaries
mkdir -p /mnt/packages

if [ ! -f /mnt/iso/boot/packages.sfs ]; then
    echo "No packages..."
fi

mount -t squashfs -o loop /mnt/iso/boot/packages.sfs /mnt/packages

echo "Mounted"

# Create the Writable Layer in RAM
mount -t tmpfs tmpfs /mnt/rw_layer
mkdir -p /mnt/rw_layer/upper /mnt/rw_layer/work

# Combine them using OverlayFS
mount -t overlay overlay -o lowerdir=/mnt/ro_root,upperdir=/mnt/rw_layer/upper,workdir=/mnt/rw_layer/work /mnt/merged

# Prepare the transition
# We move the ISO mount so the new system can see it (optional but helpful)
mkdir -p /mnt/merged/mnt/iso
mkdir -p /mnt/merged/mnt/packages
mount --move /mnt/iso /mnt/merged/mnt/iso
mount --move /mnt/packages /mnt/merged/mnt/packages

echo "Booting Pullinux system..."
exec switch_root /mnt/merged /sbin/init

EOF

echo ""
echo "Creating initramfs..."
echo ""

INITFILE=/usr/share/pullinux/liveiso/init mkinitramfs 6.18.10

mkdir -p /usr/share/pullinux/liveiso/rootfs

mkdir -p /usr/share/pullinux/liveiso/iso/boot/grub/

echo "Installing base system..."

plx-install base-system -d /usr/share/pullinux/liveiso/rootfs

# un-mount virtual envs...
CHRENV=/usr/share/pullinux/liveiso/rootfs
mountpoint -q $CHRENV/dev/shm && umount $CHRENV/dev/shm
umount $CHRENV/dev/pts
umount $CHRENV/{sys,proc,run,dev}

echo ""
echo "Copying package data..."
echo ""

mkdir -p /usr/share/pullinux/liveiso/rootfs/usr/share/pullinux/packages/

shopt -s extglob
cp -ra /usr/share/pullinux/packages/!(bin) /usr/share/pullinux/liveiso/rootfs/usr/share/pullinux/packages/

mkdir -p /usr/share/pullinux/liveiso/rootfs/etc/systemd/system/getty@tty1.service.d

cat > /usr/share/pullinux/liveiso/rootfs/etc/systemd/system/getty@tty1.service.d/override.conf << "EOF"
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I $TERM

EOF

#fix root so it's bootable with no password...
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

cp /usr/bin/plx-install /usr/share/pullinux/liveiso/rootfs/usr/bin/
cp /usr/bin/plx-build /usr/share/pullinux/liveiso/rootfs/usr/bin/
cp /usr/bin/mount-virt.sh /usr/share/pullinux/liveiso/rootfs/usr/bin/

echo ""
echo "Squashing root file system..."
echo ""

mksquashfs /usr/share/pullinux/liveiso/rootfs /usr/share/pullinux/liveiso/iso/boot/rootfs.sfs -e boot

echo ""
echo "Copying boot files..."
echo ""

mv initrd.img-6.18.10 /usr/share/pullinux/liveiso/iso/boot/
cp /boot/vmlinuz-6.18.10-plx-3.0 /usr/share/pullinux/liveiso/iso/boot/


cat > /usr/share/pullinux/liveiso/iso/boot/grub/grub.cfg << "EOF"
set default=0
set timeout=5

menuentry "Pullinux Live Install" {
    # Load the kernel
    linux /boot/vmlinuz-6.18.10-plx-3.0 root=/dev/ram0 rw earlyprintk loglevel=7 

    # Load the initramfs
    initrd /boot/initrd.img-6.18.10
}

menuentry "Pullinux Live Install (serial console)" {
    # Load the kernel
    linux /boot/vmlinuz-6.18.10-plx-3.0 root=/dev/ram0 rw earlyprintk loglevel=7 console=ttyS0,115200

    # Load the initramfs
    initrd /boot/initrd.img-6.18.10
}

EOF


echo ""
echo "Squashing package files..."
echo ""

mksquashfs /usr/share/pullinux/packages/bin /usr/share/pullinux/liveiso/packages.sfs -no-compression

echo ""
echo "Creating initial grub ISO..."
echo ""

#grub-mkrescue -o /usr/share/pullinux/liveiso/pullinux-live.iso \
#    /usr/share/pullinux/liveiso/iso/ \
#    -- -as mkisofs -iso-level 3 -graft-points \
#    "/boot/packages.sfs=/usr/share/pullinux/liveiso/packages.sfs" \
#    --append_partition 2 0xef /usr/lib/grub/i386-pc/eltorito.img \
#    -appended_part_as_gpt

grub-mkrescue -o /usr/share/pullinux/liveiso/pullinux-live.iso \
    /usr/share/pullinux/liveiso/iso/ \
    -- -as mkisofs -iso-level 3 -graft-points \
    "/boot/packages.sfs=/usr/share/pullinux/liveiso/packages.sfs"





#grub-mkrescue -o /usr/share/pullinux/liveiso/pullinux-live.iso \
#/usr/share/pullinux/liveiso/iso/ \
#-- -as mkisofs -iso-level 3


#mksquashfs /usr/share/pullinux/packages/bin /usr/share/pullinux/liveiso/iso/boot/packages.sfs -no-compression

#echo ""
#echo "Updating ISO with packages..."
#echo ""

#xorriso -dev /usr/share/pullinux/liveiso/pullinux-live.iso -osirrox on --compliance iso_9660_level=3 -map /usr/share/pullinux/liveiso/iso/boot/packages.sfs /boot/packages.sfs -commit






#xorriso -as mkisofs -o /usr/share/pullinux/liveiso/pullinux-live.iso -graft-points -volid "PLX_LIVE" -iso-level 3 /usr/share/pullinux/liveiso/iso/

#grub-mkrescue -o /usr/share/pullinux/liveiso/pullinux-live.iso /usr/share/pullinux/liveiso/iso/ -- -volid "PLX_LIVE"

echo ""
echo "Live ISO Created: /usr/share/pullinux/liveiso/pullinux-live.iso"
