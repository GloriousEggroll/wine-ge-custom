#!/bin/bash
echo -e "ubuntu\nubuntu" | passwd ubuntu
echo 'ubuntu ALL=NOPASSWD: /usr/bin/apt' | sudo EDITOR='tee -a' visudo
echo 'ubuntu ALL=NOPASSWD: /usr/bin/apt-get' | sudo EDITOR='tee -a' visudo
echo 'ubuntu ALL=NOPASSWD: /usr/bin/dpkg' | sudo EDITOR='tee -a' visudo