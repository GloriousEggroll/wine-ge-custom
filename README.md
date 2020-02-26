Requirements:  

-Vagrant with sshfs plugin  
-libvirt or VirtualBox installed  

Notes:
* It is important to note that the wine, wine-staging and game-patches-testing repos/folders are here for my personal use. The build bot does -NOT- pull from any of these folders directly. 
-- It is recommended to replace te wine repository with a clone of your own wine repository, then run ./game-patches-testing/protonprep.sh to apply my changes to your own wine repository, and commit + push those changes to a separate branch on your -own- repository. THEN follow the instructions below, using your own repository URL and branch.

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