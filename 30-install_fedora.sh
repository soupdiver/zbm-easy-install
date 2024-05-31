#!/bin/bash
set -e

os = $1
ROOT_PASSWORD = $2
HOSTNAME = $3

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

mount -t proc /proc /mnt/proc
mount -t sysfs /sys /mnt/sys
mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts

dnf --releasever=${VERSION_ID} -y --installroot=/mnt install kernel grub2
dnf --releasever=${VERSION_ID} -y --installroot=/mnt groupinstall "Minimal Install"
dnf --releasever=${VERSION_ID} -y --installroot=/mnt install dnf

# mv /mnt/etc/resolv.conf /mnt/etc/resolv.conf.orig
rm -f /mnt/etc/resolv.conf || true
cp -L /etc/resolv.conf /mnt/etc/resolv.conf
cp /etc/hostid /mnt/etc

# workaround SELinux and chaning root password foo
setenforce 0
mount -o remount rw /mnt
