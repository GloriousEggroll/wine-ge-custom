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

  #ubuntu2204-based build VM
  config.vm.define "ubuntu2204", primary: true do |ubuntu2204|

    ubuntu2204.vm.box = "generic/ubuntu2204"

    ubuntu2204.vm.synced_folder "./vagrant_share/", "/vagrant/", create: true, type: "sshfs", sshfs_opts_append: "-o cache=no"
    ubuntu2204.vm.synced_folder ".", "/home/vagrant/lutris-buildbot", id: "lutris-buildbot", type: "rsync", rsync__exclude: ["vagrant_share"]

    ubuntu2204.vm.provision "shell-1", type: "shell", inline: <<-SHELL

      #install dependencies on host vm
      apt-get update      
      apt-get install -y sshpass debootstrap

      snap install distrobuilder --edge --classic

      # add vagrant user to lxd group to allow lxc permissions
      usermod -aG lxd vagrant

      # setup lxc containers
      wget https://raw.githubusercontent.com/lxc/lxc-ci/main/images/ubuntu.yaml
      
      # TODO: migrate this from bionic to jammy after we figure out building 32 wine inside 64 bit container
      # https://github.com/lutris/buildbot/issues/175
      distrobuilder build-lxd ubuntu.yaml -o image.architecture=i386 -o image.release=bionic
      mv incus.tar.xz ubuntu32.tar.xz
      mv rootfs.squashfs rootfs32.squashfs

      # TODO: migrate this from bionic to jammy after we figure out building 32 wine inside 64 bit container
      # https://github.com/lutris/buildbot/issues/175
      distrobuilder build-lxd ubuntu.yaml -o image.architecture=amd64 -o image.release=bionic
      mv incus.tar.xz ubuntu64.tar.xz
      mv rootfs.squashfs rootfs64.squashfs

      lxc image import ubuntu32.tar.xz rootfs32.squashfs --alias ubuntu32
      lxc image import ubuntu64.tar.xz rootfs64.squashfs --alias ubuntu64

    SHELL
  end
end
