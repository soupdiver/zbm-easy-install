#!/bin/bash
set -e

cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian bookworm main contrib
deb-src http://deb.debian.org/debian bookworm main contrib
EOF
apt update

apt install -y htop nala
nala install -y debootstrap gdisk dkms linux-headers-$(uname -r)
nala install -y zfsutils-linux python3

zgenhostid -f 0x00bab10c
