#!/bin/bash

# usage: ./docker-winebuild.sh name winerepo branch
# example: ./docker-winebuild.sh lutris-GE https://github.com/GloriousEggroll/proton-wine Proton8-15
# build name output: vagrant_share/wine-lutris-GE-Proton8-15-x86_64.tar.xz

if [[ ! -d vagrant_share ]]; then
	mkdir -p vagrant_share
fi
if [[ -z $(podman container list -a | grep buildbot) ]]; then
	docker create --interactive --name buildbot --mount type=bind,source="$PWD"/vagrant_share,destination=/vagrant,rw=true docker.io/gloriouseggroll/lutris_buildbot:bookworm
fi

docker start buildbot

# cleanup any old builds first
docker exec buildbot bash -c "cd /home/vagrant/lutris-buildbot && git config --global --add safe.directory /home/vagrant/lutris-buildbot"
docker exec buildbot bash -c "cd /home/vagrant/lutris-buildbot && git reset --hard HEAD && git clean -xdf && git pull"
docker exec buildbot bash -c "rm -Rf /home/vagrant/lutris-buildbot/runners/wine/wine-src/"

# start build
docker exec buildbot bash -c "cd /home/vagrant/lutris-buildbot/runners/wine && ./build.sh --as $1 --version $3 --with $2 --branch $3"

docker stop buildbot

