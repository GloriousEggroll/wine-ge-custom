#!/bin/bash

chown -R ubuntu:ubuntu ~/.ssh/config
cat /dev/zero | ssh-keygen -q -N ""
sshpass -p "ubuntu" ssh-copy-id -o StrictHostKeyChecking=no ubuntu@buildbot32
