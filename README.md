# armhf-bootstrap

## Usage:

$ ./bootstrap.sh [-q|-v]
# chroot arm_linux
# cd /root/kernel
# [make linux-config]
# make
...
PROFIT

### Also, you can set variables:
* DIST - choose distributive different, than Debian 8 'Jessie'
* ARCH - choose architecture (default amd64)
* DESTINATION - choose destination (default arm_linux)
* INCLUDES - choose additional packages to install (not recommended to change)

