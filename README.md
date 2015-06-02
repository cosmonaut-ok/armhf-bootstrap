# armhf-bootstrap

## Usage:

```bash
root@host # ./bootstrap.sh [-q|-v]
root@host # chroot arm_linux
root@arm-chroot-YYYY-MM-DD # cd /root/kernel
root@arm-chroot-YYYY-MM-DD # [make linux-config]
root@arm-chroot-YYYY-MM-DD # make
```
...

PROFIT

### Also, you can set variables:
* DIST - choose distributive different, than Debian 8 'Jessie'
* ARCH - choose architecture (default amd64)
* DESTINATION - choose destination (default arm_linux)
* INCLUDES - choose additional packages to install (not recommended to change)

