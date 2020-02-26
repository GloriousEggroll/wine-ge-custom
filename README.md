Requirements:  

-Vagrant with sshfs plugin  
-libvirt or VirtualBox installed  

Instructions:  

$ git clone --recurse-submodules https://github.com/gloriouseggroll/wine-ge-custom  
$ cd wine-ge-custom  
$ vagrant up  
$ ./makebuild.sh name winerepo branch  

Example: ./makebuild.sh lutris http://github.com/gloriouseggroll/wine ge-5.2  

Final build will be placed in wine-ge-custom/vagrant_share/ with name format wine-name-branch-x86_64.tar.gz:  

Example: wine-lutris-ge-5.2-x86_64.tar.xz  

Build installation:  

1) Extract wine-name-branch-x86_64.tar.gz to /home/USERNAME/.local/share/lutris/runners/wine/  
2) Restart lutris. You can now choose wine-name-branch-x86_64 from the runners list in configuration options for any game.  