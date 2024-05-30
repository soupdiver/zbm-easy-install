#!/bin/bash
set -e

debootstrap bookworm /mnt

cp /etc/hostid /mnt/etc
cp /etc/resolv.conf /mnt/etc

mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
mount -B /dev /mnt/dev
mount -t devpts pts /mnt/dev/pts
