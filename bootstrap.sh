#!/bin/bash

case $1 in
    "-v")
        VERBOSE=yes
        ;;
    "-q")
        QUIET=yes
        ;;
    "")
        :
        ;;
    *)
        printf "Usage:\n    -q quiet\n    -v verbose\n"
        exit 1
        ;;
esac

if [ $UID != 0 ]; then
    if [ -z $QUIET ]; then
        echo "Not root. Exiting"
    fi
    exit 1
fi

function msg_n ()
{
    [ -z $QUIET ] && echo -n $@
}
function msg ()
{
    [ -z $QUIET ] && echo  $@
}

[ ! -z $VERBOSE ] && set -x
msg_n "Setting variables... "
[ -z $DIST ] && DIST=jessie
[ -z $ARCH ] && ARCH=amd64
[ -z $DESTINATION ] && DESTINATION=arm_linux
[ -z $INCLUDES ] && INCLUDES=build-essential,git,u-boot-tools,texinfo,texlive,ccache,zlib1g-dev,gawk,bison,flex,gettext,uuid-dev,locales,libusb-1.0-0-dev,gcc,g++,git-core,libncurses5-dev,lib32z1,lib32stdc++6,libgusb-dev,pkg-config
[ ! -z $QUIET ] && GIT_OPT="-q"
[ ! -z $VERBOSE ] && GIT_OPT="-v"
[ ! -z $VERBOSE ] && DEBOOTSTRAP_OPT="--verbose"
msg "DONE"

msg_n  "Detecting OS... "
if [ ! -z "$(which yum 2>/dev/null)" ]; then
    msg "RedHat-based"
    PKG_INST="yum install -y -q"
    PKG_FIND="yum search"
    PKG_CHECK_INSTLLED="dpkg -s"
    PKG_DEL="yum erase -y -q"
elif [ ! -z "$(which apt-get 2>/dev/null)" ]; then
    msg "Debian-based"
    PKG_INST="apt-get install -y"
    PKG_FIND="apt-get search"
    PKG_DEL="apt-get remove -y"
fi

function ensure_install ()
{
    msg_n "Checking if $1 installed... "
    if [ ! -z $1 ] && $PKG_CHECK_INSTLLED $1 >/dev/null 2>&1; then
        msg_n "Not installed. Installing... "
        $PKG_INST $1
        msg "DONE"
    fi
    msg "Installed"
}

ensure_install debootstrap
ensure_install qemu

# ensure_install debian-archive-keyring
ensure_install git
ensure_install binfmt-support
ensure_install qemu
ensure_install qemu-user-static
ensure_install qemu-system
ensure_install qemu-kvm
ensure_install parted

msg "Bootstrapping..."
debootstrap $DEBOOTSTRAP_OPT --include=$INCLUDES --arch=$ARCH $DIST $DESTINATION
msg "DONE"

if [ $? == 0 ]; then
    msg "Clonning kernel repo... "
    cd $DESTINATION/root
    git clone $GIT_OPT https://github.com/pcduino/kernel.git
    git submodule update --init
    msg "DONE"
    wget "https://launchpad.net/linaro-toolchain-binaries/trunk/2013.10/+download/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux.tar.xz" -O gcc-cross.tar.xz
    tar -xvf gcc-cross.tar.xz
    echo "PATH=$PATH:$/root/(ls -d gcc-linaro-arm*)/bin" >> .bashrc
    cd ../..
    msg "DONE"
fi

msg "Clonning build repo... "
git clone $GIT_OPT https://github.com/ingmar-k/Allwinner_A10_Debian.git
msg "DONE"

msg "Setting defauult locale to en_US.UTF-8... "
sed -i 's/\#\ en\_US\.UTF\-8\ UTF\-8/en\_US\.UTF\-8\ UTF\-8/g' $DESTINATION/etc/locale.gen
echo 'LANG=en_US.UTF-8' > $DESTINATION/etc/default/locale

echo "arm-chroot-`date +%F`" > $DESTINATION/etc/hostname
chroot $DESTINATION locale-gen
msg "DONE"

./mount.sh $DESTINATION

# cp linux-config $DESTINATION/root/kernel/build/sun4i_defconfig-linux/.config
# chroot $DESTINATION cd /root/kernel && make

