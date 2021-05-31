#!/bin/bash
set -x

container=$1
user='ubuntu'

InstallDependencies() {
    lxc exec $container -- apt update
    lxc exec $container -- apt -y full-upgrade
    # this package is necessary to add repositories using add-apt-repository
    lxc exec $container -- apt -y install software-properties-common
    lxc exec $container -- apt -y install wget curl build-essential git python openssh-server s3cmd awscli vim zsh fontconfig sshpass
    lxc exec $container -- add-apt-repository ppa:cybermax-dexter/sdl2-backport -y
    lxc exec $container -- add-apt-repository ppa:cybermax-dexter/vkd3d -y
    lxc exec $container -- apt update
}

SetupSSH() {
    lxc exec $container -- mkdir -p /home/$user/.ssh
    lxc exec $container -- chown ubuntu /home/$user/.ssh
    lxc file push ~/.ssh/config $container/home/$user/.ssh/
}

SetupUserspace() {
    lxc file push -r lutris-buildbot/buildbot $container/home/$user/
}

SetupHost() {
    if [[ $container == *"64"* ]]; then
        other_container="${container%amd64}i386"
        other_hostname="buildbot32"
    else
        other_container="${container%i386}amd64"
        other_hostname="buildbot64"
    fi
    other_ip=$(lxc list $other_container -c 4 | grep eth0 | cut -d" " -f 2)
    if [[ "$other_ip" = "" ]]; then
        echo "Other container $other_container is not reachable"
        exit 2
    fi
    lxc exec $container -- bash -c "echo $other_ip   $other_hostname >> /etc/hosts"
}

if [ $2 ]; then
    $2
else
    InstallDependencies
    SetupHost
    SetupSSH
    SetupUserspace
fi
