#!/bin/bash
set -e

BOOT_DISK=$1
POOL_DISK=$2
BOOT_PART=$3
POOL_PART=$4
POOL_DEVICE=$5

source /etc/os-release
export ID

zpool labelclear -f "$POOL_DISK" || true

wipefs -f -a "$POOL_DISK"
wipefs -f -a "$BOOT_DISK"

sgdisk --zap-all "$POOL_DISK"
sgdisk --zap-all "$BOOT_DISK"

echo Create EFI boot partition
sgdisk -n "${BOOT_PART}:1m:+512m" -t "${BOOT_PART}:ef00" "$BOOT_DISK"

echo Create zpool partition
sgdisk -n "${POOL_PART}:0:-10m" -t "${POOL_PART}:bf00" "$POOL_DISK"

echo Create zpool
zpool create -f -o ashift=12 \
 -O compression=lz4 \
 -O acltype=posixacl \
 -O xattr=sa \
 -O relatime=on \
 -o autotrim=on \
 -m none zroot "$POOL_DEVICE"

# -o compatibility=openzfs-2.1-linux \

echo Create initial file systems
zfs create -o mountpoint=none zroot/ROOT
zfs create -o mountpoint=/ -o canmount=noauto zroot/ROOT/${ID}
zfs create -o mountpoint=/home zroot/home

zpool set bootfs=zroot/ROOT/${ID} zroot

echo export and mount to /mnt
zpool export zroot
zpool import -N -R /mnt zroot -d /dev/disk/by-id
zfs mount zroot/ROOT/${ID}
zfs mount zroot/home

echo Update device symlinks
udevadm trigger
