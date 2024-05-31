#!/bin/bash
set -e

source /etc/os-release
export ID

apt update
apt install debootstrap gdisk zfsutils-linux
