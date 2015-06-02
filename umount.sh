#!/bin/bash

if [ ! -z $1 ]; then
    for i in /dev /proc /sys; do
	umount "$1""$i"
    done
fi
