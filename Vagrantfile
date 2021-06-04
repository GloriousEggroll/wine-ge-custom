# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 2.2.0"

module OS
  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end
end

# Vagrant file for setting up a build environment for Lutris wine builds.
if OS.linux?
  cpus = `nproc`.to_i
  # meminfo shows KB and we need to convert to MB
  memory = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
elsif OS.mac?
  cpus = `sysctl -n hw.physicalcpu`.to_i
  # sysctl shows bytes and we need to convert to MB
  memory = `sysctl hw.memsize | sed -e 's/hw.memsize: //'`.to_i / 1024 / 1024 / 4
else
  cpus = 1
  memory = 1024
  puts "Vagrant launched from unsupported platform."
end
memory = [memory, 4096].max
puts "Platform: " + cpus.to_s + " CPUs, " + memory.to_s + " MB memory"

Vagrant.configure(2) do |config|
  #libvirt doesn't have a decent synced folder, so we have to use vagrant-sshfs.
  #This is not needed for virtualbox, but I couldn't find a way to use a
  #different synced folder type per provider, so we always use it.
  config.vagrant.plugins = "vagrant-sshfs"

  config.vm.provider "virtualbox" do |v|
    v.cpus = [cpus, 32].min     # virtualbox limit is 32 cpus
    v.memory = memory
  end

  #ubuntu1804-based build VM
  config.vm.define "ubuntu1804", primary: true do |ubuntu1804|

    ubuntu1804.vm.box = "generic/ubuntu1804"

    ubuntu1804.vm.synced_folder "./vagrant_share/", "/vagrant/", create: true, type: "sshfs", sshfs_opts_append: "-o cache=no"
    ubuntu1804.vm.synced_folder ".", "/home/vagrant/lutris-buildbot", id: "lutris-buildbot", type: "rsync", rsync__exclude: ["vagrant_share"]

    ubuntu1804.vm.provision "shell-1", type: "shell", inline: <<-SHELL

      #install dependencies on host vm
      apt-get update
      apt-get install -y lxd lxd-client sshpass

      # add vagrant user to lxd group to allow lxc permissions
      usermod -aG lxd vagrant

    SHELL
    ubuntu1804.vm.provision "shell-2", type: "shell", after: "shell-1", :privileged => false, inline: <<-SHELL

      echo "setup lxc containers"
      cat lutris-buildbot/buildbot/preseed | lxd init --preseed
      lxc launch images:ubuntu/bionic/i386 buildbot-bionic-i386
      lxc launch images:ubuntu/bionic/amd64 buildbot-bionic-amd64
      
      # (0) setup ubuntu user on both containers
      lxc file push lutris-buildbot/0-buildbot-usersetup.sh buildbot-bionic-i386/home/ubuntu/
      lxc exec buildbot-bionic-i386 -- sudo bash -c /home/ubuntu/0-buildbot-usersetup.sh
      lxc file push lutris-buildbot/0-buildbot-usersetup.sh buildbot-bionic-amd64/home/ubuntu/
      lxc exec buildbot-bionic-amd64 -- sudo bash -c /home/ubuntu/0-buildbot-usersetup.sh

      # (1) setup host file on VM
      # this must be done otherwise one of the machines wont have an IP available for the setup.sh script.
      echo "Sleeping for 10 seconds to allow both containers to be fully started."
      sleep 10
      ./lutris-buildbot/1-setup-container-networking.sh buildbot-bionic-i386 buildbot-bionic-amd64
      # view to verify IPs for both machines have been added to ~/.ssh/config
      cat ~/.ssh/config
      
      # (2) setup /etc/hosts file and buildbot files on containers
      cd ~/lutris-buildbot/buildbot
      ./setup-container.sh buildbot-bionic-i386
      ./setup-container.sh buildbot-bionic-amd64
      cd ~

      # setup ssh keys from host to both containers
      cat /dev/zero | ssh-keygen -q -N ""
      sshpass -p "ubuntu" ssh-copy-id -o StrictHostKeyChecking=no ubuntu@buildbot-bionic-i386
      sshpass -p "ubuntu" ssh-copy-id -o StrictHostKeyChecking=no ubuntu@buildbot-bionic-amd64

      # (3) setup ssh keys from 32 bit container to 64 bit container
      lxc file push lutris-buildbot/3-buildbot32-sshsetup.sh buildbot-bionic-i386/home/ubuntu/
      lxc exec buildbot-bionic-i386 -- sudo --login --user ubuntu ./3-buildbot32-sshsetup.sh

      # (4) setup ssh keys from 64 bit container to 32 bit container
      lxc file push lutris-buildbot/4-buildbot64-sshsetup.sh buildbot-bionic-amd64/home/ubuntu/
      lxc exec buildbot-bionic-amd64 -- sudo --login --user ubuntu ./4-buildbot64-sshsetup.sh

    SHELL
  end
end
