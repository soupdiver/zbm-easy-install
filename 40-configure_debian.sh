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
OS=$9

# echo $HOSTNAME > /etc/hostname
echo -e "127.0.1.1\t$HOSTNAME" >> /etc/hosts

# echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd root

export DEBIAN_FRONTEND=noninteractive

if [ $OS == "debian" ]; then
    cat <<EOF > /etc/apt/sources.list
deb http://ftp.de.debian.org/debian bookworm main contrib
deb-src http://ftp.de.debian.org/debian bookworm main contrib

deb http://ftp.de.debian.org/debian-security bookworm-security main contrib
deb-src http://ftp.de.debian.org/debian-security/ bookworm-security main contrib

deb http://ftp.de.debian.org/debian bookworm-updates main contrib
deb-src http://ftp.de.debian.org/debian bookworm-updates main contrib

deb http://ftp.de.debian.org/debian bookworm-backports main contrib
deb-src http://ftp.de.debian.org/debian bookworm-backports main contrib
EOF
fi

if [ $OS == "ubuntu" ]; then
    cat <<EOF > /etc/apt/sources.list
# Uncomment the deb-src entries if you need source packages

deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse
# deb-src http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
# deb-src http://archive.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse

deb http://archive.canonical.com/ubuntu/ jammy partner
# deb-src http://archive.canonical.com/ubuntu/ jammy partner
EOF
fi

apt update
apt install -y nala

nala install -y locales keyboard-configuration console-setup
dpkg-reconfigure locales tzdata keyboard-configuration console-setup

nala install -y linux-headers-amd64 linux-image-amd64 zfs-initramfs dosfstools
echo "REMAKE_INITRD=yes" > /etc/dkms/zfs.conf

systemctl enable zfs.target
systemctl enable zfs-import-cache
systemctl enable zfs-mount
systemctl enable zfs-import.target

update-initramfs -c -k all

nala install -y efibootmgr curl
