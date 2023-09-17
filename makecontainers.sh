#!/bin/bash

      export VAGRANT_DEFAULT_PROVIDER=virtualbox

      # Start the ubuntu 2204 vagrant host and build the bionic 1804 LXC containers inside it
      vagrant up

      # Prepare the bionic 1804 containers for lutris builds
      vagrant ssh -c 'echo "setup buildbot inside lxc containers"'
      vagrant ssh -c 'cat lutris-buildbot/buildbot/preseed | lxd init --preseed'
      vagrant ssh -c 'lxc launch ubuntu32 buildbot-i386'
      vagrant ssh -c 'lxc launch ubuntu64 buildbot-amd64'
      
      # (0) setup ubuntu user on both containers
      vagrant ssh -c 'lxc file push lutris-buildbot/0-buildbot-usersetup.sh buildbot-i386/home/ubuntu/'
      vagrant ssh -c 'lxc exec buildbot-i386 -- sudo bash -c /home/ubuntu/0-buildbot-usersetup.sh'
      vagrant ssh -c 'lxc file push lutris-buildbot/0-buildbot-usersetup.sh buildbot-amd64/home/ubuntu/'
      vagrant ssh -c 'lxc exec buildbot-amd64 -- sudo bash -c /home/ubuntu/0-buildbot-usersetup.sh'

      # (1) setup host file on VM
      # this must be done otherwise one of the machines wont have an IP available for the setup.sh script.
      vagrant ssh -c 'echo "Sleeping for 10 seconds to allow both containers to be fully started."'
      vagrant ssh -c 'sleep 10'
      vagrant ssh -c './lutris-buildbot/1-setup-container-networking.sh buildbot-i386 buildbot-amd64'
      # view to verify IPs for both machines have been added to ~/.ssh/config
      vagrant ssh -c 'cat ~/.ssh/config'
      
      # (2) setup /etc/hosts file and buildbot files on containers
      vagrant ssh -c 'cd ~/lutris-buildbot/buildbot && ./setup-container.sh buildbot-i386 && ./setup-container.sh buildbot-amd64'

      # setup ssh keys from host to both containers
      vagrant ssh -c 'cat /dev/zero | ssh-keygen -q -N ""'
      vagrant ssh -c 'sshpass -p "ubuntu" ssh-copy-id -o StrictHostKeyChecking=no ubuntu@buildbot-i386'
      vagrant ssh -c 'sshpass -p "ubuntu" ssh-copy-id -o StrictHostKeyChecking=no ubuntu@buildbot-amd64'

      # (3) setup ssh keys from 32 bit container to 64 bit container
      vagrant ssh -c 'lxc file push lutris-buildbot/3-buildbot32-sshsetup.sh buildbot-i386/home/ubuntu/'
      vagrant ssh -c 'lxc exec buildbot-i386 -- sudo --login --user ubuntu ./3-buildbot32-sshsetup.sh'

      # (4) setup ssh keys from 64 bit container to 32 bit container
      vagrant ssh -c 'lxc file push lutris-buildbot/4-buildbot64-sshsetup.sh buildbot-amd64/home/ubuntu/'
      vagrant ssh -c 'lxc exec buildbot-amd64 -- sudo --login --user ubuntu ./4-buildbot64-sshsetup.sh'

      # Halt the 2204 host when complete
      vagrant halt
