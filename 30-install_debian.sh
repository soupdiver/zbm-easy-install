#!/bin/bash
set -e

os=$1
ROOT_PASSWORD=$2
HOSTNAME=$3

mirror=""

case $os in
    debian)
        os="bookworm"
        ;;
    ubuntu)
        os="jammy"
        mirror="http://de.archive.ubuntu.com/ubuntu/"
        ;;
    *)
        echo "OS $os not supported"
        exit 1
        ;;
esac

debootstrap $os /mnt $mirror

mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts

# cp /etc/hostid /mnt/etc
cp /etc/resolv.conf /mnt/etc

systemd-firstboot \
--root=/mnt \
--locale=en_US.UTF-8 \
--hostname=$HOSTNAME \
--root-password=$ROOT_PASSWORD \
--setup-machine-id

#--keymap=tr-intl \
#--timezone=Europe/Istanbul \
