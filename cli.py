import subprocess
import argparse
import os
import glob
import shutil


def parse_args():
    parser = argparse.ArgumentParser(
        description='Install ZFS boot menu on Debian.')
    parser.add_argument('--boot-disk', required=True,
                        help='The boot disk, e.g., /dev/sda')
    parser.add_argument('--pool-disk', required=True,
                        help='The pool disk, e.g., /dev/sda')
    parser.add_argument('--boot-partition', required=True,
                        type=int, help='The boot partition number, e.g., 1')
    parser.add_argument('--pool-partition', required=True,
                        type=int, help='The pool partition number, e.g., 2')
    parser.add_argument('--os', required=True,
                        choices=['debian', 'fedora', 'ubuntu'], help='The operating system to install')
    parser.add_argument('--hostname', required=True,
                        help='The hostname for the new system')
    parser.add_argument('--root-password', required=True,
                        help='The root password for the new system')

    return parser.parse_args()


def main():
    args = parse_args()

    boot_disk = args.boot_disk
    pool_disk = args.pool_disk
    boot_part = args.boot_partition
    pool_part = args.pool_partition
    os_type = args.os
    hostname = args.hostname
    root_password = args.root_password

    # Detect if the user specified the same disk for boot and pool
    if boot_disk == pool_disk and boot_part == pool_part:
        raise ValueError(
            'Boot and pool partitions must be different if they are on the same disk.')

    # Handle NVMe devices
    if boot_disk.startswith('/dev/nvme'):
        boot_device = f'{boot_disk}p{boot_part}'
    else:
        boot_device = f'{boot_disk}{boot_part}'

    if pool_disk.startswith('/dev/nvme'):
        pool_device = f'{pool_disk}p{pool_part}'
    else:
        pool_device = f'{pool_disk}{pool_part}'

    # Print the extracted variables (for debugging purposes)
    print(f'BOOT_DISK: {boot_disk}')
    print(f'BOOT_PART: {boot_part}')
    print(f'BOOT_DEVICE: {boot_device}')
    print(f'POOL_DISK: {pool_disk}')
    print(f'POOL_PART: {pool_part}')
    print(f'POOL_DEVICE: {pool_device}')
    print(f'OS: {os_type}')
    print(f'HOSTNAME: {hostname}')

    prepare_live_script = f"./10-prepare_live_{os_type}.sh"
    subprocess.run([prepare_live_script], check=True)

    prepare_disks_script = f"./20-prepare_disks.sh"
    subprocess.run([prepare_disks_script, boot_disk, pool_disk,
                   str(boot_part), str(pool_part), pool_device], check=True)

    install_os_script = f"./30-install_{os_type}.sh"
    subprocess.run([install_os_script, os_type,
                   root_password, hostname], check=True)

    # Call the configure_{os}.sh script
    c_os_script = f"./40-configure*.sh"
    for file in glob.glob(c_os_script):
        shutil.copy(file, "/mnt")
    subprocess.run(['chroot',
                    '/mnt',
                    '/bin/bash',
                    '-c',
                    f"{c_os_script} {boot_disk} {pool_disk} {boot_part} {pool_part} {boot_device} {pool_device} {hostname} {root_password}"
                    ], check=True)

    c_os_script = f"./50-install-zbm.sh"
    shutil.copy(c_os_script, f"/mnt/50-install-zbm.sh")
    subprocess.run(['chroot',
                    '/mnt',
                    '/bin/bash',
                    '-c',
                    f"{c_os_script} {boot_disk} {pool_disk} {boot_part} {pool_part} {
                        boot_device} {pool_device} {hostname} {root_password}"
                    ], check=True)

    # Call the post_install.sh script
    post_install_script = './60-post_install.sh'
    subprocess.run([post_install_script], check=True)

    # os.remove('/mnt/configure_os.sh')

    print('ZFS BootMenu installation complete.\nPlease reboot the system.')


if __name__ == '__main__':
    # print('Running cli.py')
    main()
