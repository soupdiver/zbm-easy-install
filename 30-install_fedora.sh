#!/bin/bash
set -e

source /etc/os-release
export ID

# mkdir /run/install
# mount /dev/mapper/live-base /run/install

# rsync -pogAXtlHrDx \
#  --stats \
#  --exclude=/boot/efi/* \
#  --exclude=/etc/machine-id \
#  --info=progress2 \
#  /run/install/ /mnt

mkdir /mnt/proc || true
mkdir /mnt/sys || true
mkdir /mnt/dev || true
mkdir /mnt/dev/pts || true

mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts
mount -o remount rw /mnt

dnf --releasever=${VERSION_ID} -y --installroot=/mnt install kernel grub2
dnf --releasever=${VERSION_ID} -y --installroot=/mnt groupinstall "Minimal Install"
dnf --releasever=${VERSION_ID} -y --installroot=/mnt install dnf

# mv /mnt/etc/resolv.conf /mnt/etc/resolv.conf.orig
rm -f /mnt/etc/resolv.conf || true
cp -L /etc/resolv.conf /mnt/etc/resolv.conf
cp /etc/hostid /mnt/etc
