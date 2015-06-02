#!/bin/bash

if [ ! -z $1 ]; then
    for i in /dev /proc /sys; do
	mount -o bind $i "$1""$i"
    done
fi
