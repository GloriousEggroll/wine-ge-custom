#!/bin/bash
echo -e "ubuntu\nubuntu" | passwd ubuntu
sudo EDITOR='tee -a' echo 'ubuntu ALL=NOPASSWD: ALL' | visudo
