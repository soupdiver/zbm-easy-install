#!/bin/bash
set -e

BOOT_DISK=$1
POOL_DISK=$2
BOOT_PART=$3
POOL_PART=$4
BOOT_DEVICE=$5
POOL_DEVICE=$6
HOSTNAME=$7
ROOT_PASSWORD=$8

zfs set org.zfsbootmenu:commandline="quiet" zroot/ROOT
mkfs.vfat -F32 "$BOOT_DEVICE"

cat << EOF >> /etc/fstab
$( blkid | grep "$BOOT_DEVICE" | cut -d ' ' -f 2 ) /boot/efi vfat defaults 0 0
EOF

mkdir -p /boot/efi
mount /boot/efi

mkdir -p /boot/efi/EFI/ZBM
curl -o /boot/efi/EFI/ZBM/VMLINUZ.EFI -L https://get.zfsbootmenu.org/efi
cp /boot/efi/EFI/ZBM/VMLINUZ.EFI /boot/efi/EFI/ZBM/VMLINUZ-BACKUP.EFI

mount -t efivarfs efivarfs /sys/firmware/efi/efivars

efibootmgr -c -d "$BOOT_DISK" -p "$BOOT_PART" \
  -L "ZFSBootMenu (Backup)" \
  -l '\EFI\ZBM\VMLINUZ-BACKUP.EFI'

efibootmgr -c -d "$BOOT_DISK" -p "$BOOT_PART" \
  -L "ZFSBootMenu" \
  -l '\EFI\ZBM\VMLINUZ.EFI'

# reset the resolv.conf on Fedora install
# todo: make nicer
if [ -f /etc/resolv.conf.orig ]; then
  mv /etc/resolv.conf.orig /etc/resolv.conf
fi
