#!/bin/bash
set -e

umount -l -n -R /mnt
zpool export zroot

# reboot
