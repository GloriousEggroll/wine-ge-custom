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

# Vagrant file for setting up a build environment for Proton.
if OS.linux?
  cpus = `nproc`.to_i
  # meminfo shows KB and we need to convert to MB
  memory = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 2
elsif OS.mac?
  cpus = `sysctl -n hw.physicalcpu`.to_i
  # sysctl shows bytes and we need to convert to MB
  memory = `sysctl hw.memsize | sed -e 's/hw.memsize: //'`.to_i / 1024 / 1024 / 2
else
  cpus = 1
  memory = 1024
  puts "Vagrant launched from unsupported platform."
end
puts "Platform: " + cpus.to_s + " CPUs, " + memory.to_s + " MB memory"

Vagrant.configure(2) do |config|
  #libvirt doesn't have a decent synced folder, so we have to use vagrant-sshfs.
  #This is not needed for virtualbox, but I couldn't find a way to use a
  #different synced folder type per provider, so we always use it.
  config.vagrant.plugins = "vagrant-sshfs"

  config.vm.provider "virtualbox" do |v|
    v.cpus = cpus
    v.memory = memory
  end

  config.vm.provider "libvirt" do |v|
    v.cpus = cpus
    v.memory = memory
    v.random_hostname = true
    v.default_prefix = ENV['USER'].to_s.dup.concat('_').concat(File.basename(Dir.pwd))
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

      # setup lxc containers
      cat lutris-buildbot/buildbot/preseed | lxd init --preseed
      lxc launch images:ubuntu/bionic/i386 buildbot-bionic-i386
      lxc launch images:ubuntu/bionic/amd64 buildbot-bionic-amd64

      # setup ubuntu user on both containers
      lxc file push lutris-buildbot/buildbot-usersetup.sh buildbot-bionic-i386/home/ubuntu/
      lxc exec buildbot-bionic-i386 -- bash -c /home/ubuntu/buildbot-usersetup.sh
      lxc file push lutris-buildbot/buildbot-usersetup.sh buildbot-bionic-amd64/home/ubuntu/
      lxc exec buildbot-bionic-amd64 -- bash -c /home/ubuntu/buildbot-usersetup.sh

      # setup host file on VM
      cd lutris-buildbot/buildbot
      echo "Sleeping for 10 seconds to allow both containers to be fully started."
      sleep 10 # this must be done otherwise one of the machines wont have an IP available for the setup.sh script.
      ./setup.sh buildbot-bionic-i386 buildbot-bionic-amd64
      cat ~/.ssh/config # view to verify IPs for both machines have been added to ~/.ssh/config

      # setup dependencies, repositories, files on containers
      ./setup-container.sh buildbot-bionic-i386
      ./setup-container.sh buildbot-bionic-amd64

      cd ~

      # setup ssh keys from host to both containers
      cat /dev/zero | ssh-keygen -q -N ""
      sshpass -p "ubuntu" ssh-copy-id -o StrictHostKeyChecking=no ubuntu@buildbot-bionic-i386
      sshpass -p "ubuntu" ssh-copy-id -o StrictHostKeyChecking=no ubuntu@buildbot-bionic-amd64

      # setup ssh keys from 32 bit container to 64 bit container
      lxc file push lutris-buildbot/buildbot32-sshsetup.sh buildbot-bionic-i386/home/ubuntu/
      lxc exec buildbot-bionic-i386 -- sudo --login --user ubuntu ./buildbot32-sshsetup.sh

      # setup ssh keys from 64 bit container to 32 bit container
      lxc file push lutris-buildbot/buildbot64-sshsetup.sh buildbot-bionic-amd64/home/ubuntu/
      lxc exec buildbot-bionic-amd64 -- sudo --login --user ubuntu ./buildbot64-sshsetup.sh

    SHELL
  end
end
