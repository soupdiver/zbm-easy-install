#!/bin/bash

umount -l -R /mnt
zpool destroy rpool
