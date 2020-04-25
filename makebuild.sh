#!/bin/bash

# usage: ./makebuild.sh name winerepo branch
# example: ./makebuild.sh lutris http://github.com/gloriouseggroll/wine ge-5.2
# build name output: wine-lutris-ge-5.2-x86_64.tar.xz

vagrant up

# cleanup any old builds first
vagrant ssh -c 'ssh ubuntu@buildbot-bionic-amd64 "cd buildbot && git reset --hard HEAD && git clean -xdf"'
vagrant ssh -c 'ssh ubuntu@buildbot-bionic-i386 "cd buildbot && git reset --hard HEAD && git clean -xdf"'

# start build
vagrant ssh -c "ssh ubuntu@buildbot-bionic-amd64 \"cd buildbot/runners/wine && ./build.sh --as $1 --version $3 --with $2 --branch $3 --noupload --keep --dependencies\""

vagrant ssh -c 'ssh ubuntu@buildbot-bionic-amd64 "mv buildbot/runners/wine/wine-*.tar.xz ~/"'
vagrant ssh -c 'scp ubuntu@buildbot-bionic-amd64:/home/ubuntu/wine-*.tar.xz /vagrant/'
vagrant ssh -c 'ssh ubuntu@buildbot-bionic-amd64 "rm ~/wine-*.tar.xz"'

vagrant halt
