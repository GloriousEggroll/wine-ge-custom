#!/bin/bash
set -e
vagrant ssh -c "cd lutris-buildbot; git pull origin master"
vagrant ssh -c "lxc file push -r lutris-buildbot/buildbot buildbot-i386/home/ubuntu/"
vagrant ssh -c "lxc file push -r lutris-buildbot/buildbot buildbot-amd64/home/ubuntu/"
echo "Buildbot updated"
