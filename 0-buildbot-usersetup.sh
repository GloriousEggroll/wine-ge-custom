#!/bin/bash
echo -e "ubuntu\nubuntu" | passwd ubuntu
echo 'ubuntu ALL=NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo
