#!/bin/bash
set -e

source /etc/os-release
export ID

rpm -e --nodeps zfs-fuse || true
dnf config-manager --disable updates
dnf install -y https://zfsonlinux.org/fedora/zfs-release-2-5$(rpm --eval "%{dist}").noarch.rpm
dnf install -y https://dl.fedoraproject.org/pub/fedora/linux/releases/${VERSION_ID}/Everything/x86_64/os/Packages/k/kernel-devel-$(uname -r).rpm
dnf install -y zfs gdisk
modprobe zfs

zgenhostid -f 0x00bab10c
