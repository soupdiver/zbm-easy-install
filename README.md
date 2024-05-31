# zbm-easy-install

## Warning: In Development

The goal is to provide an easy installation routine to setup a new machine with zfsbootmenu.

## Usage

1. Start a Debian or Fedora live system from an iso image
1. `git clone https://github.com/soupdiver/zbm-easy-install`
1. `python3 cli.py --boot-disk /dev/BOOTDISK --boot-partition 1 --pool-disk /dev/POOLDISK --pool-partition 2 --hostname foohost --os debian --root-password "12"`

### Disks

1. You can use the same disk for boot and pool or different ones. Make sure to set the partition arguments accordingly

## Limitations

1. At the moment the used disks will be wiped and the zpool will use the entire disk.
1. Debian installations come up with no network configured.

## Roadmap

1. Support more distributions
1. Support more advanced disk layouts
1. Support more initial os configuration
