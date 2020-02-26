#!/bin/bash

chown -R ubuntu:ubuntu ~/.ssh/config
cat /dev/zero | ssh-keygen -q -N ""
sudo apt -y install sshpass
sshpass -p "ubuntu" ssh-copy-id -o StrictHostKeyChecking=no ubuntu@buildbot64
exit