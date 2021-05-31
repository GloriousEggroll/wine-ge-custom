#!/bin/bash

if [[ -z $1 ]]; then
	echo "Usage: ./setup.sh <32-bit-container-name> <64-bit-container-name>"
	exit
elif [[ -z $2 ]]; then
	echo "Usage: ./setup.sh <32-bit-container-name> <64-bit-container-name>"
	exit
fi

if [[ $1 == *"64"* ]]; then
	LX64="$1"
	LX32="$2"
else
	LX64="$2"
	LX32="$1"
fi

IP32=$(lxc list | grep $LX32 | cut -d " " -f7)
IP64=$(lxc list | grep $LX64 | cut -d " " -f6)

cat > sshconfig <<EOF

#configured for host
    Host $LX64
        Hostname $IP64
        User ubuntu

    Host $LX32
        Hostname $IP32
        User ubuntu

#configured for containers
    Host buildbot64
        Hostname $IP64
        User ubuntu

    Host buildbot32
        Hostname $IP32
        User ubuntu

EOF
cat ~/.ssh/config sshconfig > ~/.ssh/config

