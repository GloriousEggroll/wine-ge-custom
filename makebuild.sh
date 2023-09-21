#!/bin/bash

# usage: ./docker-winebuild.sh name winerepo branch
# example: ./docker-winebuild.sh lutris-GE https://github.com/GloriousEggroll/proton-wine Proton8-15
# build name output: vagrant_share/wine-lutris-GE-Proton8-15-x86_64.tar.xz

if [[ ! -d vagrant_share ]]; then
	mkdir -p vagrant_share
fi
if [[ -z $(podman container list -a | grep buildbot) ]]; then
	docker create --interactive --name buildbot --mount type=bind,source="$PWD"/vagrant_share,destination=/vagrant,readonly=false --mount type=bind,source="$PWD"/buildbot,destination=/home/vagrant/buildbot,readonly=false docker.io/gloriouseggroll/lutris_buildbot:latest
fi

docker start buildbot

# cleanup any old builds first
docker exec buildbot bash -c "rm -Rf /home/vagrant/buildbot/runners/wine/wine-src/"

# start build
docker exec buildbot bash -c "cd /home/vagrant/buildbot/runners/wine && ./build.sh --as $1 --version $3 --with $2 --branch $3"

docker stop buildbot
