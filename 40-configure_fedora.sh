#!/bin/sh
set -e

BOOT_DISK=$1
POOL_DISK=$2
BOOT_PART=$3
POOL_PART=$4
BOOT_DEVICE=$5
POOL_DEVICE=$6
HOSTNAME=$7
ROOT_PASSWORD=$8

source /etc/os-release

# needed to set password, not 100% sure why though
# https://askubuntu.com/a/514959

chmod 600 /etc/shadow
touch /etc/shadow
echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd root

restorecon -v /etc/shadow

cat << EOF > /etc/dracut.conf.d/zol.conf
nofsck="yes"
add_dracutmodules+=" zfs "
omit_dracutmodules+=" btrfs "
EOF

rpm -e --nodeps zfs-fuse || true

dnf config-manager --disable updates

dnf install -y https://dl.fedoraproject.org/pub/fedora/linux/releases/${VERSION_ID}/Everything/x86_64/os/Packages/k/kernel-devel-$(uname -r).rpm

dnf --releasever=${VERSION_ID} install -y \
  https://zfsonlinux.org/fedora/zfs-release-2-5$(rpm --eval "%{dist}").noarch.rpm

dnf install -y zfs zfs-dracut efibootmgr curl

dnf config-manager --enable updates

dracut --force --regenerate-all

fixfiles -F onboot
