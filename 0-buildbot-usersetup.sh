#!/bin/bash
echo -e "ubuntu\nubuntu" | passwd ubuntu
echo 'ubuntu ALL=NOPASSWD: ALL' | EDITOR='tee -a' visudo
